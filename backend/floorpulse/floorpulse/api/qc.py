import frappe
from frappe.utils import today

from floorpulse.api.utils import ensure_dict, require_permission


QI_STATUSES = ("Accepted", "Rejected")


def inspection_error(status, ncr):
    if status not in QI_STATUSES:
        return "status must be Accepted or Rejected"
    if status == "Rejected" and not ncr:
        return "NCR details are required when rejecting an inspection"
    if status == "Rejected" and not ncr.get("defect_type"):
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


@frappe.whitelist()
def submit_inspection(quality_inspection, status, ncr=None):
    ncr = ensure_dict(ncr) if ncr else {}
    error = inspection_error(status, ncr)
    if error:
        frappe.throw(error)

    qi = frappe.get_doc("Quality Inspection", quality_inspection)
    require_permission("Quality Inspection", "submit", qi)

    if qi.docstatus == 1:
        frappe.throw("Quality Inspection is already submitted")
    if qi.docstatus == 2:
        frappe.throw("Quality Inspection is cancelled")

    try:
        qi.status = status
        qi.save()
        qi.submit()

        ncr_name = None
        if status == "Rejected":
            require_permission("NCR", "create")
            ncr_doc = frappe.get_doc(ncr_payload_from_qi(qi, ncr))
            ncr_doc.insert()
            ncr_name = ncr_doc.name

        return {
            "quality_inspection": qi.name,
            "status": qi.status,
            "ncr": ncr_name,
        }
    except Exception:
        frappe.db.rollback()
        raise
