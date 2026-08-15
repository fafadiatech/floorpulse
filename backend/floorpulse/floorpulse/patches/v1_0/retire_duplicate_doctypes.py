"""Remove custom DocTypes and fields that duplicate ERPNext built-ins."""

import frappe

from floorpulse.setup.install import OBSOLETE_CUSTOM_FIELDS

RETIRED_DOCTYPES = ("QC Inspection", "Maintenance Job")


def execute():
    _delete_retired_doctypes()
    _delete_obsolete_custom_fields()


def _delete_retired_doctypes():
    for dt in RETIRED_DOCTYPES:
        if not frappe.db.exists("DocType", dt):
            continue
        for name in frappe.get_all(dt, pluck="name"):
            frappe.delete_doc(dt, name, force=1, ignore_permissions=True)
        frappe.delete_doc("DocType", dt, force=1, ignore_permissions=True)


def _delete_obsolete_custom_fields():
    for dt, fieldname in OBSOLETE_CUSTOM_FIELDS:
        name = frappe.db.get_value(
            "Custom Field", {"dt": dt, "fieldname": fieldname}, "name"
        )
        if name:
            frappe.delete_doc("Custom Field", name, force=1, ignore_permissions=True)
