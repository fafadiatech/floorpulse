import frappe

from floorpulse.api.utils import as_mapping


# First match is primary_role. Collect unique shells for roles[].
ROLE_SHELL_MAP = (
    ("Quality Manager", "qc"),
    ("Stock Manager", "warehouse"),
    ("Stock User", "warehouse"),
    ("Sales Manager", "sales"),
    ("Sales User", "sales"),
    ("Maintenance Manager", "maintenance"),
    ("Maintenance User", "maintenance"),
    ("Manufacturing Manager", "production"),
    ("Manufacturing User", "production"),
)

VALID_SHELLS = ("qc", "warehouse", "sales", "maintenance", "production")


def shells_from_roles(role_names):
    role_set = set(role_names or [])
    shells = []
    for erp_role, shell in ROLE_SHELL_MAP:
        if erp_role in role_set and shell not in shells:
            shells.append(shell)
    return shells


def get_user_shells(user=None):
    return shells_from_roles(frappe.get_roles(user or frappe.session.user))


def _employee_for_user(user):
    row = frappe.db.get_value(
        "Employee",
        {"user_id": user, "status": "Active"},
        ["name", "employee_name", "department"],
        as_dict=True,
    )
    if row:
        return as_mapping(row)
    row = frappe.db.get_value(
        "Employee",
        {"user_id": user},
        ["name", "employee_name", "department"],
        as_dict=True,
    )
    return as_mapping(row) if row else None


def _sales_person_for_employee(employee_name):
    if not employee_name:
        return None
    return frappe.db.get_value("Sales Person", {"employee": employee_name, "enabled": 1}, "name")


def _default_warehouse(user, employee):
    warehouse = None
    defaults = getattr(frappe, "defaults", None)
    if defaults:
        warehouse = defaults.get_user_default("Warehouse", user)
    if warehouse:
        return warehouse
    if employee:
        meta = frappe.get_meta("Employee")
        if meta.has_field("default_warehouse"):
            return frappe.db.get_value("Employee", employee["name"], "default_warehouse")
    return None


@frappe.whitelist()
def get_session():
    user = frappe.session.user
    if not user or user == "Guest":
        frappe.throw("Not logged in")

    user_doc = frappe.get_doc("User", user)
    roles = get_user_shells(user)
    employee = _employee_for_user(user)

    return {
        "user": user,
        "full_name": user_doc.full_name or user,
        "employee": employee,
        "primary_role": roles[0] if roles else None,
        "roles": roles,
        "default_warehouse": _default_warehouse(user, employee),
        "sales_person": _sales_person_for_employee(employee["name"] if employee else None),
    }
