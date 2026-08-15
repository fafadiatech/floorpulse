import frappe

from floorpulse.api.utils import ensure_list, require_permission


OPEN_TASK_STATUSES = ("Pending", "In Progress")
REQUIRES_REFERENCE = {"GRN", "Picking", "Returns Processing"}
TERMINAL_STATUSES = {"Completed", "Cancelled"}


def task_error(status, docstatus, task_type, reference_document):
    if docstatus == 1:
        return "Warehouse Task is already submitted"
    if docstatus == 2:
        return "Warehouse Task is cancelled"
    if status in TERMINAL_STATUSES:
        return f"Warehouse Task is {status}"
    if task_type in REQUIRES_REFERENCE and not reference_document:
        return f"{task_type} task requires a reference document"
    return None


def apply_item_lines(items, lines, qty_field="qty"):
    if not lines:
        return
    by_item = {line.get("item_code"): line for line in lines if line.get("item_code")}
    for item in items:
        item_code = item.get("item_code") if isinstance(item, dict) else item.item_code
        line = by_item.get(item_code)
        if not line:
            continue
        if line.get("qty") is not None:
            if isinstance(item, dict):
                item[qty_field] = line["qty"]
            else:
                setattr(item, qty_field, line["qty"])
        for field in ("batch_no", "serial_no"):
            if line.get(field):
                if isinstance(item, dict):
                    item[field] = line[field]
                else:
                    setattr(item, field, line[field])


def _as_doc(value):
    if hasattr(value, "insert"):
        return value
    if isinstance(value, str) and value.lstrip().startswith("{"):
        value = frappe.parse_json(value)
    if isinstance(value, dict):
        return frappe.get_doc(value)
    return value


def _company_for_warehouse(warehouse):
    return frappe.db.get_value("Warehouse", warehouse, "company")


def _line_qty(line):
    return line.get("qty") if line.get("qty") is not None else 0


def _submit_stock_doc(doc):
    if not doc.name or doc.is_new():
        doc.insert(ignore_permissions=False)
    else:
        doc.save()
    doc.submit()
    return doc


def _post_grn(task, lines):
    if task.reference_doctype != "Purchase Order":
        frappe.throw("GRN task must reference a Purchase Order")
    from erpnext.buying.doctype.purchase_order.purchase_order import make_purchase_receipt

    pr = _as_doc(make_purchase_receipt(task.reference_document))
    apply_item_lines(pr.items, lines)
    pr.fp_grn_task_reference = task.name
    return _submit_stock_doc(pr)


def _stock_entry_items(task, lines, purpose):
    items = []
    from_wh = None
    to_wh = None
    if purpose == "Material Issue":
        from_wh = task.warehouse
    elif purpose == "Material Receipt":
        to_wh = task.warehouse
    else:
        from_wh = task.source_bin or task.warehouse
        to_wh = task.target_bin or task.warehouse

    for line in lines:
        row = {
            "item_code": line["item_code"],
            "qty": _line_qty(line),
        }
        if from_wh:
            row["s_warehouse"] = line.get("from_bin") or from_wh
        if to_wh:
            row["t_warehouse"] = line.get("to_bin") or to_wh
        if line.get("batch_no"):
            row["batch_no"] = line["batch_no"]
        if line.get("serial_no"):
            row["serial_no"] = line["serial_no"]
        items.append(row)
    return items, from_wh, to_wh


def _post_stock_entry(task, lines, purpose):
    if not lines:
        frappe.throw("lines are required for this task type")
    items, from_wh, to_wh = _stock_entry_items(task, lines, purpose)
    doc = frappe.get_doc(
        {
            "doctype": "Stock Entry",
            "stock_entry_type": purpose,
            "purpose": purpose,
            "company": _company_for_warehouse(task.warehouse),
            "from_warehouse": from_wh if purpose != "Material Receipt" else None,
            "to_warehouse": to_wh if purpose != "Material Issue" else None,
            "items": items,
        }
    )
    return _submit_stock_doc(doc)


def _post_picking(task, lines):
    if task.reference_doctype != "Pick List":
        frappe.throw("Picking task must reference a Pick List")
    pick_list = frappe.get_doc("Pick List", task.reference_document)
    apply_item_lines(getattr(pick_list, "locations", []) or [], lines, qty_field="picked_qty")
    if pick_list.docstatus == 0:
        pick_list.save()
        pick_list.submit()

    purpose = (pick_list.purpose or "Delivery").strip()
    if purpose == "Delivery":
        from erpnext.stock.doctype.pick_list.pick_list import create_delivery_note

        posted = _as_doc(create_delivery_note(pick_list.name))
    else:
        from erpnext.stock.doctype.pick_list.pick_list import create_stock_entry

        posted = _as_doc(create_stock_entry(pick_list.name))
    return _submit_stock_doc(posted)


def _post_cycle_count(task, lines):
    if not lines:
        frappe.throw("lines are required for Cycle Count")
    items = []
    for line in lines:
        items.append(
            {
                "item_code": line["item_code"],
                "warehouse": line.get("from_bin") or line.get("to_bin") or task.warehouse,
                "qty": _line_qty(line),
                "batch_no": line.get("batch_no"),
            }
        )
    doc = frappe.get_doc(
        {
            "doctype": "Stock Reconciliation",
            "purpose": "Stock Reconciliation",
            "company": _company_for_warehouse(task.warehouse),
            "items": items,
        }
    )
    return _submit_stock_doc(doc)


def _post_returns(task, lines):
    if task.reference_doctype == "Purchase Receipt":
        from erpnext.controllers.sales_and_purchase_return import make_return_doc

        posted = _as_doc(make_return_doc("Purchase Receipt", task.reference_document))
        apply_item_lines(posted.items, lines)
        return _submit_stock_doc(posted)
    if task.reference_doctype == "Delivery Note":
        from erpnext.controllers.sales_and_purchase_return import make_return_doc

        posted = _as_doc(make_return_doc("Delivery Note", task.reference_document))
        apply_item_lines(posted.items, lines)
        return _submit_stock_doc(posted)
    return _post_stock_entry(task, lines, "Material Receipt")


HANDLERS = {
    "GRN": _post_grn,
    "Put-Away": lambda task, lines: _post_stock_entry(task, lines, "Material Transfer"),
    "Stock Transfer": lambda task, lines: _post_stock_entry(task, lines, "Material Transfer"),
    "Issue": lambda task, lines: _post_stock_entry(task, lines, "Material Issue"),
    "Picking": _post_picking,
    "Cycle Count": _post_cycle_count,
    "Returns Processing": _post_returns,
}


def _assert_assignee(task_doc):
    assigned = task_doc.assigned_to
    if not assigned or assigned == frappe.session.user:
        return
    if "Stock Manager" in frappe.get_roles(frappe.session.user):
        return
    frappe.throw("Warehouse Task is assigned to another user")


@frappe.whitelist()
def execute_task(task, lines=None):
    lines = ensure_list(lines)
    task_doc = frappe.get_doc("Warehouse Task", task)
    require_permission("Warehouse Task", "submit", task_doc)
    _assert_assignee(task_doc)

    error = task_error(
        task_doc.status, task_doc.docstatus, task_doc.task_type, task_doc.reference_document
    )
    if error:
        frappe.throw(error)

    handler = HANDLERS.get(task_doc.task_type)
    if not handler:
        frappe.throw(f"Unsupported task type: {task_doc.task_type}")

    try:
        posted = handler(task_doc, lines)
        task_doc.reload()
        if task_doc.status == "Pending":
            task_doc.status = "In Progress"
            task_doc.save()
        task_doc.submit()
        return {
            "task": task_doc.name,
            "status": task_doc.status,
            "posted_doctype": posted.doctype,
            "posted_name": posted.name,
        }
    except Exception:
        frappe.db.rollback()
        raise


@frappe.whitelist()
def dispatch(delivery_note, vehicle_number, driver_name=None):
    if not vehicle_number:
        frappe.throw("vehicle_number is required")

    dn = frappe.get_doc("Delivery Note", delivery_note)
    require_permission("Delivery Note", "submit", dn)

    if dn.docstatus == 1:
        frappe.throw("Delivery Note is already submitted")
    if dn.docstatus == 2:
        frappe.throw("Delivery Note is cancelled")

    try:
        dn.submit()

        existing = frappe.db.exists(
            "Gate Entry",
            {
                "vehicle_number": vehicle_number,
                "purpose": "Delivery",
                "status": "Open",
            },
        )
        remarks = f"Delivery Note {dn.name}"
        if existing:
            ge = frappe.get_doc("Gate Entry", existing)
            require_permission("Gate Entry", "write", ge)
            ge.status = "Closed"
            if driver_name:
                ge.driver_name = driver_name
            ge.party = dn.customer
            ge.remarks = f"{ge.remarks}\n{remarks}".strip() if ge.remarks else remarks
            ge.save()
        else:
            require_permission("Gate Entry", "create")
            ge = frappe.get_doc(
                {
                    "doctype": "Gate Entry",
                    "vehicle_number": vehicle_number,
                    "driver_name": driver_name,
                    "party": dn.customer,
                    "purpose": "Delivery",
                    "status": "Closed",
                    "remarks": remarks,
                }
            )
            ge.insert()

        return {
            "delivery_note": dn.name,
            "status": "Submitted",
            "gate_entry": ge.name,
        }
    except Exception:
        frappe.db.rollback()
        raise
