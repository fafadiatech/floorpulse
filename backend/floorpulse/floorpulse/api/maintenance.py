import frappe
from frappe.utils import now_datetime

from floorpulse.api.utils import ensure_dict, require_permission


def normalize_readings(readings):
    out = {}
    for key, value in (readings or {}).items():
        out[str(key)] = float(value)
    return out


def primary_reading(readings):
    if not readings:
        return None
    if "Hours" in readings:
        return readings["Hours"]
    return next(iter(readings.values()))


@frappe.whitelist()
def close_job(asset_repair, signature=None, checklist_completed=None):
    repair = frappe.get_doc("Asset Repair", asset_repair)
    require_permission("Asset Repair", "submit", repair)

    if repair.docstatus == 1:
        frappe.throw("Asset Repair is already submitted")
    if repair.docstatus == 2:
        frappe.throw("Asset Repair is cancelled")

    try:
        if signature:
            repair.fp_customer_signature = signature
        if checklist_completed is not None:
            repair.fp_checklist_completed = 1 if int(checklist_completed) else 0
        elif signature:
            repair.fp_checklist_completed = 1

        repair.repair_status = "Completed"
        if not repair.completion_date:
            repair.completion_date = now_datetime()
        repair.save()
        repair.submit()

        removed = []
        for row in frappe.get_all(
            "LOTO",
            filters={"asset": repair.asset, "status": "Applied"},
            fields=["name", "reference_document"],
        ):
            if row.reference_document and row.reference_document != repair.name:
                continue
            loto = frappe.get_doc("LOTO", row.name)
            require_permission("LOTO", "write", loto)
            loto.status = "Removed"
            loto.save()
            removed.append(loto.name)

        return {
            "asset_repair": repair.name,
            "status": repair.repair_status,
            "loto_removed": removed,
        }
    except Exception:
        frappe.db.rollback()
        raise


@frappe.whitelist()
def save_meter_readings(asset, readings):
    readings = normalize_readings(ensure_dict(readings))
    if not readings:
        frappe.throw("readings are required")

    asset_doc = frappe.get_doc("Asset", asset)
    require_permission("Asset", "write", asset_doc)

    primary = primary_reading(readings)
    asset_doc.fp_meter_reading = primary
    asset_doc.fp_meter_readings = readings
    asset_doc.save()

    return {
        "asset": asset_doc.name,
        "fp_meter_reading": asset_doc.fp_meter_reading,
        "readings": readings,
    }
