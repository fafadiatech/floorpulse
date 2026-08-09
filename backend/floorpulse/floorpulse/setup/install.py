import frappe


def after_install():
    _create_custom_fields()
    _hide_other_workspaces()


def after_migrate():
    _create_custom_fields()
    _hide_other_workspaces()


def _hide_other_workspaces():
    """Hide all standard ERPNext workspaces so only FloorPulse is visible by default."""
    others = frappe.get_all(
        "Workspace",
        filters={"name": ["!=", "FloorPulse"]},
        pluck="name",
    )
    for ws in others:
        frappe.db.set_value("Workspace", ws, "is_hidden", 1)
    if others:
        frappe.db.commit()


def _create_custom_fields():
    from frappe.custom.doctype.custom_field.custom_field import create_custom_fields

    create_custom_fields(CUSTOM_FIELDS, ignore_validate=True)


# Custom fields added to standard ERPNext DocTypes to support FloorPulse workflows.
# Each entry is a list of field dicts accepted by Frappe's create_custom_fields().
CUSTOM_FIELDS = {
    # ── Customer ──────────────────────────────────────────────────────────────
    "Customer": [
        {
            "fieldname": "fp_segment",
            "label": "Segment",
            "fieldtype": "Select",
            "options": "\nRetail\nWholesale\nEnterprise\nGovernment",
            "insert_after": "customer_type",
        },
        {
            "fieldname": "fp_credit_limit",
            "label": "Credit Limit",
            "fieldtype": "Currency",
            "insert_after": "fp_segment",
        },
        {
            "fieldname": "fp_payment_terms",
            "label": "Payment Terms (Days)",
            "fieldtype": "Int",
            "default": "30",
            "insert_after": "fp_credit_limit",
        },
    ],
    # ── Sales Order ───────────────────────────────────────────────────────────
    "Sales Order": [
        {
            "fieldname": "fp_visit_reference",
            "label": "Customer Visit Reference",
            "fieldtype": "Link",
            "options": "Customer Visit",
            "insert_after": "customer",
        },
        {
            "fieldname": "fp_approval_status",
            "label": "Field Approval Status",
            "fieldtype": "Select",
            "options": "\nPending\nApproved\nRejected",
            "default": "Pending",
            "insert_after": "fp_visit_reference",
        },
    ],
    # ── Maintenance Visit ─────────────────────────────────────────────────────
    "Maintenance Visit": [
        {
            "fieldname": "fp_technician",
            "label": "Assigned Technician",
            "fieldtype": "Link",
            "options": "Employee",
            "insert_after": "customer",
        },
        {
            "fieldname": "fp_checklist_completed",
            "label": "Checklist Completed",
            "fieldtype": "Check",
            "insert_after": "fp_technician",
        },
        {
            "fieldname": "fp_customer_signature",
            "label": "Customer Signature",
            "fieldtype": "Attach Image",
            "insert_after": "fp_checklist_completed",
        },
    ],
    # ── Asset ─────────────────────────────────────────────────────────────────
    "Asset": [
        {
            "fieldname": "fp_asset_tag",
            "label": "Asset Tag",
            "fieldtype": "Data",
            "insert_after": "asset_name",
            "unique": 1,
        },
        {
            "fieldname": "fp_meter_reading",
            "label": "Current Meter Reading",
            "fieldtype": "Float",
            "insert_after": "fp_asset_tag",
        },
        {
            "fieldname": "fp_next_pm_date",
            "label": "Next PM Date",
            "fieldtype": "Date",
            "insert_after": "fp_meter_reading",
        },
    ],
    # ── Purchase Receipt ──────────────────────────────────────────────────────
    "Purchase Receipt": [
        {
            "fieldname": "fp_grn_task_reference",
            "label": "GRN Task Reference",
            "fieldtype": "Link",
            "options": "Warehouse Task",
            "insert_after": "supplier",
        },
    ],
}
