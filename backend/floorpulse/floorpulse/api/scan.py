import frappe

from floorpulse.api.utils import as_mapping


# After erpnext.stock.utils.scan_barcode, try these in order.
SCAN_FALLBACKS = (
    ("Asset", "fp_asset_tag"),
    ("Asset", "name"),
    ("Job Card", "name"),
    ("Work Order", "name"),
    ("Purchase Order", "name"),
    ("Bin", "name"),
    ("Warehouse Task", "name"),
)

LABEL_FIELDS = {
    "Asset": "asset_name",
    "Job Card": "operation",
    "Work Order": "production_item",
    "Purchase Order": "supplier",
    "Bin": "item_code",
    "Warehouse Task": "task_type",
    "Item": "item_name",
    "Batch": "item",
    "Serial No": "item_code",
}


def scan_hit(type_, doctype, name, label=None, extra=None):
    return {
        "type": type_,
        "doctype": doctype,
        "name": name,
        "label": label or name,
        "extra": extra or {},
    }


def from_barcode_scan(data):
    data = as_mapping(data)
    if not data:
        return None
    if data.get("serial_no"):
        return scan_hit("Serial", "Serial No", data["serial_no"], data["serial_no"], data)
    if data.get("batch_no"):
        return scan_hit("Batch", "Batch", data["batch_no"], data["batch_no"], data)
    if data.get("item_code"):
        return scan_hit("Item", "Item", data["item_code"], data.get("item_name") or data["item_code"], data)
    return None


def _label_for(doctype, name):
    field = LABEL_FIELDS.get(doctype)
    if not field:
        return name
    value = frappe.db.get_value(doctype, name, field)
    return value or name


def _exists(doctype, filters):
    try:
        return frappe.db.exists(doctype, filters)
    except Exception:
        return None


def resolve_code(code):
    code = (code or "").strip()
    if not code:
        return None

    try:
        from erpnext.stock.utils import scan_barcode

        barcode_hit = from_barcode_scan(scan_barcode(code))
        if barcode_hit:
            if barcode_hit["doctype"] == "Item":
                barcode_hit["label"] = _label_for("Item", barcode_hit["name"])
            return barcode_hit
    except Exception:
        pass

    for doctype, field in SCAN_FALLBACKS:
        filters = code if field == "name" else {field: code}
        name = _exists(doctype, filters)
        if name:
            extra = {}
            if doctype == "Asset":
                extra["asset_tag"] = frappe.db.get_value(doctype, name, "fp_asset_tag")
            return scan_hit(doctype, doctype, name, _label_for(doctype, name), extra)

    return None


@frappe.whitelist()
def resolve(code):
    hit = resolve_code(code)
    if not hit:
        frappe.throw(f"No match for code: {code}")
    return hit
