import frappe


def after_install():
    _configure_system_settings()
    _create_custom_fields()
    _delete_obsolete_custom_fields()
    _reload_floorpulse_workspace()
    _hide_other_workspaces()


def after_migrate():
    _configure_system_settings()
    _create_custom_fields()
    _delete_obsolete_custom_fields()
    _reload_floorpulse_workspace()
    _hide_other_workspaces()


def _configure_system_settings():
    """Allow short demo usernames (production, qc, …) and skip password policy."""
    if not frappe.db.exists("DocType", "System Settings"):
        return
    frappe.db.set_single_value("System Settings", "enable_password_policy", 0)
    frappe.db.set_single_value("System Settings", "allow_login_using_user_name", 1)
    frappe.db.commit()


def _reload_floorpulse_workspace():
    """Re-import the FloorPulse workspace JSON so Desk cards stay in sync."""
    frappe.reload_doc("FloorPulse", "workspace", "floorpulse", force=True)
    if not _workspace_has_layout():
        if frappe.db.exists("Workspace", "FloorPulse"):
            frappe.delete_doc(
                "Workspace", "FloorPulse", force=1, ignore_permissions=True
            )
        frappe.reload_doc("FloorPulse", "workspace", "floorpulse", force=True)
    if frappe.db.exists("Workspace", "FloorPulse"):
        frappe.db.set_value("Workspace", "FloorPulse", "is_hidden", 0)
        frappe.db.set_value("Workspace", "FloorPulse", "public", 1)
    frappe.clear_cache()


def _workspace_has_layout():
    if not frappe.db.exists("Workspace", "FloorPulse"):
        return False
    content = frappe.db.get_value("Workspace", "FloorPulse", "content") or "[]"
    if content.strip() in ("", "[]"):
        return False
    n_links = frappe.db.count("Workspace Link", {"parent": "FloorPulse"})
    n_shortcuts = frappe.db.count("Workspace Shortcut", {"parent": "FloorPulse"})
    return n_links > 0 and n_shortcuts > 0


def _hide_other_workspaces():
    """Hide all standard ERPNext workspaces so only FloorPulse is visible by default."""
    others = frappe.get_all(
        "Workspace",
        filters={"name": ["!=", "FloorPulse"]},
        pluck="name",
    )
    for ws in others:
        frappe.db.set_value("Workspace", ws, "is_hidden", 1)
    frappe.db.commit()


def _create_custom_fields():
    from frappe.custom.doctype.custom_field.custom_field import create_custom_fields

    create_custom_fields(CUSTOM_FIELDS, ignore_validate=True)


def _delete_obsolete_custom_fields():
    """Remove custom fields retired in favor of ERPNext built-ins."""
    for dt, fieldname in OBSOLETE_CUSTOM_FIELDS:
        name = frappe.db.get_value(
            "Custom Field", {"dt": dt, "fieldname": fieldname}, "name"
        )
        if name:
            frappe.delete_doc("Custom Field", name, force=1, ignore_permissions=True)


OBSOLETE_CUSTOM_FIELDS = [
    ("Customer", "fp_credit_limit"),
    ("Customer", "fp_payment_terms"),
    ("Sales Order", "fp_approval_status"),
]


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
    ],
    # ── Maintenance Visit (customer-site PM / field service) ──────────────────
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
    # ── Asset Repair (breakdown jobs) ─────────────────────────────────────────
    "Asset Repair": [
        {
            "fieldname": "fp_signoff_section",
            "label": "FloorPulse Sign-Off",
            "fieldtype": "Section Break",
            "insert_after": "actions_performed",
            "collapsible": 1,
        },
        {
            "fieldname": "fp_technician",
            "label": "Assigned Technician",
            "fieldtype": "Link",
            "options": "Employee",
            "insert_after": "fp_signoff_section",
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
    # ── Asset Maintenance Log (scheduled PM) ──────────────────────────────────
    "Asset Maintenance Log": [
        {
            "fieldname": "fp_checklist_completed",
            "label": "Checklist Completed",
            "fieldtype": "Check",
            "insert_after": "actions_performed",
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
            "fieldname": "fp_meter_readings",
            "label": "Named Meter Readings",
            "fieldtype": "JSON",
            "insert_after": "fp_meter_reading",
        },
        {
            "fieldname": "fp_next_pm_date",
            "label": "Next PM Date",
            "fieldtype": "Date",
            "insert_after": "fp_meter_readings",
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
    # ── Quality Inspection ────────────────────────────────────────────────────
    "Quality Inspection": [
        {
            "fieldname": "fp_verdict",
            "label": "FloorPulse Verdict",
            "fieldtype": "Select",
            "options": "\nPass\nConditional Accept\nReject",
            "insert_after": "status",
        },
    ],
    # ── Delivery Note (packing cartons / weight) ──────────────────────────────
    "Delivery Note": [
        {
            "fieldname": "fp_packing_section",
            "label": "Packing",
            "fieldtype": "Section Break",
            "insert_after": "lr_date",
            "collapsible": 1,
        },
        {
            "fieldname": "fp_carton_count",
            "label": "No. of Cartons",
            "fieldtype": "Int",
            "insert_after": "fp_packing_section",
        },
        {
            "fieldname": "fp_gross_weight",
            "label": "Gross Weight (kg)",
            "fieldtype": "Float",
            "insert_after": "fp_carton_count",
        },
        {
            "fieldname": "fp_cartons_sealed",
            "label": "Cartons Sealed",
            "fieldtype": "Check",
            "insert_after": "fp_gross_weight",
        },
        {
            "fieldname": "fp_labels_affixed",
            "label": "Shipping Labels Affixed",
            "fieldtype": "Check",
            "insert_after": "fp_cartons_sealed",
        },
    ],
}
