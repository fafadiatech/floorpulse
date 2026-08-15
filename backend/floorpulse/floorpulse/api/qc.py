import frappe
from frappe.utils import cint, today

from floorpulse.api.utils import ensure_dict, require_permission


QI_STATUSES = ("Accepted", "Rejected")
QI_VERDICTS = ("Pass", "Conditional Accept", "Reject")
VERDICT_TO_STATUS = {
    "Pass": "Accepted",
    "Conditional Accept": "Accepted",
    "Reject": "Rejected",
}
STATUS_TO_VERDICT = {
    "Accepted": "Pass",
    "Rejected": "Reject",
}
TRACE_DEPTH = 3


def resolve_verdict(status, verdict=None):
    if verdict:
        if verdict not in QI_VERDICTS:
            return None, None, "verdict must be Pass, Conditional Accept, or Reject"
        return VERDICT_TO_STATUS[verdict], verdict, None
    if status not in QI_STATUSES:
        return None, None, "status must be Accepted or Rejected"
    return status, STATUS_TO_VERDICT[status], None


def inspection_error(status, ncr, verdict=None):
    resolved_status, _resolved_verdict, error = resolve_verdict(status, verdict)
    if error:
        return error
    if resolved_status == "Rejected" and not ncr:
        return "NCR details are required when rejecting an inspection"
    if resolved_status == "Rejected" and not ncr.get("defect_type"):
        return "NCR defect_type is required when rejecting an inspection"
    return None


def ncr_payload_from_qi(qi, ncr):
    payload = {
        "doctype": "NCR",
        "item_code": ncr.get("item_code") or qi.item_code,
        "quality_inspection": qi.name,
        "reference_doctype": qi.reference_type,
        "reference_document": qi.reference_name,
        "raised_by": frappe.session.user,
        "raised_date": today(),
        "quantity_rejected": ncr.get("quantity_rejected") or qi.sample_size or 1,
        "severity": ncr.get("severity") or "Major",
        "defect_type": ncr.get("defect_type"),
        "disposition": ncr.get("disposition"),
        "notes": ncr.get("notes"),
        "root_cause": ncr.get("root_cause"),
        "corrective_action": ncr.get("corrective_action"),
        "preventive_action": ncr.get("preventive_action"),
        "capa_owner": ncr.get("capa_owner"),
        "capa_due_date": ncr.get("capa_due_date"),
    }
    return {key: value for key, value in payload.items() if value not in (None, "")}


def _release_holds(qi):
    filters = {"item_code": qi.item_code, "status": "Held"}
    batch_no = getattr(qi, "batch_no", None)
    if batch_no:
        filters["batch_no"] = batch_no
    released = []
    for name in frappe.get_all("Quality Hold", filters=filters, pluck="name"):
        hold = frappe.get_doc("Quality Hold", name)
        require_permission("Quality Hold", "write", hold)
        hold.status = "Released"
        hold.save()
        released.append(hold.name)
    if not released:
        return None
    return released[0]


@frappe.whitelist()
def submit_inspection(quality_inspection, status, ncr=None, verdict=None, release_hold=0):
    ncr = ensure_dict(ncr) if ncr else {}
    error = inspection_error(status, ncr, verdict)
    if error:
        frappe.throw(error)

    qi_status, qi_verdict, _error = resolve_verdict(status, verdict)

    qi = frappe.get_doc("Quality Inspection", quality_inspection)
    require_permission("Quality Inspection", "submit", qi)

    if qi.docstatus == 1:
        frappe.throw("Quality Inspection is already submitted")
    if qi.docstatus == 2:
        frappe.throw("Quality Inspection is cancelled")

    try:
        qi.status = qi_status
        qi.fp_verdict = qi_verdict
        qi.save()
        qi.submit()

        ncr_name = None
        if qi_status == "Rejected":
            require_permission("NCR", "create")
            ncr_doc = frappe.get_doc(ncr_payload_from_qi(qi, ncr))
            ncr_doc.insert()
            ncr_name = ncr_doc.name

        hold_released = None
        if cint(release_hold) and qi_verdict == "Pass":
            hold_released = _release_holds(qi)

        return {
            "quality_inspection": qi.name,
            "status": qi.status,
            "verdict": qi_verdict,
            "ncr": ncr_name,
            "hold_released": hold_released,
        }
    except Exception:
        frappe.db.rollback()
        raise


def _trace_node(id_, label, type_, detail, children=None):
    return {
        "id": id_,
        "label": label,
        "type": type_,
        "detail": detail,
        "children": children or [],
    }


def _item_is_product(item_code):
    if not item_code:
        return False
    return bool(
        frappe.db.exists("BOM", {"item": item_code, "is_active": 1, "is_default": 1})
        or frappe.db.exists("BOM", {"item": item_code, "is_active": 1})
    )


def _batch_tree(batch_no, visited, depth):
    if not batch_no or batch_no in visited or depth > TRACE_DEPTH:
        return None
    if not frappe.has_permission("Batch", "read", doc=batch_no):
        return None
    visited.add(batch_no)

    item_code = frappe.db.get_value("Batch", batch_no, "item")
    item_name = frappe.db.get_value("Item", item_code, "item_name") if item_code else None
    children = []

    incoming = frappe.get_all(
        "Stock Ledger Entry",
        filters={"batch_no": batch_no, "actual_qty": [">", 0], "is_cancelled": 0},
        fields=["voucher_type", "voucher_no", "item_code"],
        order_by="posting_date asc, posting_time asc",
        limit=20,
    )
    for sle in incoming:
        if sle.voucher_type == "Purchase Receipt" and frappe.has_permission(
            "Purchase Receipt", "read", doc=sle.voucher_no
        ):
            supplier = frappe.db.get_value("Purchase Receipt", sle.voucher_no, "supplier")
            if supplier:
                children.append(
                    _trace_node(supplier, supplier, "supplier", f"PR {sle.voucher_no}")
                )
        elif sle.voucher_type == "Stock Entry" and frappe.has_permission(
            "Stock Entry", "read", doc=sle.voucher_no
        ):
            purpose = frappe.db.get_value("Stock Entry", sle.voucher_no, "purpose")
            if purpose != "Manufacture":
                continue
            sources = frappe.get_all(
                "Stock Entry Detail",
                filters={"parent": sle.voucher_no},
                fields=["item_code", "item_name", "batch_no", "s_warehouse"],
            )
            for src in sources:
                if not src.s_warehouse:
                    continue
                if src.batch_no:
                    child = _batch_tree(src.batch_no, visited, depth + 1)
                    if child:
                        children.append(child)
                    continue
                label = src.item_name or src.item_code
                children.append(
                    _trace_node(src.item_code, label, "material", f"Item {src.item_code}")
                )

    return _trace_node(
        batch_no,
        item_name or batch_no,
        "batch",
        f"Item {item_code}" if item_code else "",
        children,
    )


def _tree_from_hit(hit):
    visited = set()
    doctype = hit["doctype"]
    name = hit["name"]

    if doctype == "Batch":
        node = _batch_tree(name, visited, 0)
        if node:
            return node
        item_code = frappe.db.get_value("Batch", name, "item")
        return _trace_node(name, hit.get("label") or name, "batch", f"Item {item_code or ''}")

    if doctype == "Serial No":
        batch_no = frappe.db.get_value("Serial No", name, "batch_no")
        item_code = frappe.db.get_value("Serial No", name, "item_code")
        children = []
        if batch_no:
            child = _batch_tree(batch_no, visited, 1)
            if child:
                children.append(child)
        node_type = "product" if _item_is_product(item_code) else "material"
        return _trace_node(
            name,
            hit.get("label") or name,
            node_type,
            f"Item {item_code}" if item_code else "",
            children,
        )

    if doctype == "Item":
        node_type = "product" if _item_is_product(name) else "material"
        children = []
        for batch_no in frappe.get_all("Batch", filters={"item": name}, pluck="name", limit=5):
            child = _batch_tree(batch_no, visited, 1)
            if child:
                children.append(child)
        return _trace_node(
            name,
            hit.get("label") or name,
            node_type,
            f"Item {name}",
            children,
        )

    return _trace_node(name, hit.get("label") or name, "material", doctype)


@frappe.whitelist()
def traceability(code):
    from floorpulse.api.scan import resolve_code

    hit = resolve_code(code)
    if not hit:
        frappe.throw(f"No match for code: {code}")
    return {"code": code, "root": _tree_from_hit(hit)}
