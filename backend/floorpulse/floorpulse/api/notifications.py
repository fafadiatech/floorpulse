import frappe
from frappe.utils import now_datetime, today

from floorpulse.api.auth import ROLE_SHELL_MAP


SKIP_USERS = {"Guest", "Administrator"}

SHELL_ROLES = {}
for _role, _shell in ROLE_SHELL_MAP:
    SHELL_ROLES.setdefault(_shell, []).append(_role)


def users_for_shell(shell):
    users = set()
    for role in SHELL_ROLES.get(shell) or []:
        for row in frappe.get_all(
            "Has Role",
            filters={"role": role, "parenttype": "User"},
            fields=["parent"],
        ):
            user = row.parent
            if not user or user in SKIP_USERS:
                continue
            if frappe.db.get_value("User", user, "enabled"):
                users.add(user)
    return list(users)


def notify(user, title, body, reference_doctype=None, reference_document=None, role_shell=None):
    if not user or not title:
        return None

    filters = {"for_user": user, "title": title, "read": 0}
    if reference_doctype:
        filters["reference_doctype"] = reference_doctype
    if reference_document:
        filters["reference_document"] = reference_document
    if frappe.db.exists("FloorPulse Notification", filters):
        return None

    doc = frappe.get_doc(
        {
            "doctype": "FloorPulse Notification",
            "for_user": user,
            "title": title,
            "body": body,
            "reference_doctype": reference_doctype,
            "reference_document": reference_document,
            "role_shell": role_shell,
            "read": 0,
        }
    )
    doc.insert(ignore_permissions=True)
    return doc.name


def notify_shell(shell, title, body, reference_doctype=None, reference_document=None):
    for user in users_for_shell(shell):
        notify(
            user,
            title,
            body,
            reference_doctype=reference_doctype,
            reference_document=reference_document,
            role_shell=shell,
        )


def on_ncr_insert(doc, method=None):
    title = f"NCR raised: {doc.name}"
    body = f"{doc.defect_type or 'Non-conformance'} on {doc.item_code or 'item'}"
    notify_shell("qc", title, body, reference_doctype="NCR", reference_document=doc.name)


def on_asset_repair_insert(doc, method=None):
    title = f"Repair opened: {doc.name}"
    body = doc.description or doc.asset_name or doc.asset
    notify_shell(
        "maintenance",
        title,
        body,
        reference_doctype="Asset Repair",
        reference_document=doc.name,
    )
    technician = getattr(doc, "fp_technician", None)
    if not technician:
        return
    user = frappe.db.get_value("Employee", technician, "user_id")
    if user:
        notify(
            user,
            title,
            body,
            reference_doctype="Asset Repair",
            reference_document=doc.name,
            role_shell="maintenance",
        )


def on_qi_submit(doc, method=None):
    if doc.status != "Rejected":
        return
    title = f"Inspection rejected: {doc.name}"
    body = f"{doc.item_code or 'Item'} failed quality inspection"
    notify_shell(
        "qc",
        title,
        body,
        reference_doctype="Quality Inspection",
        reference_document=doc.name,
    )


def on_quality_hold(doc, method=None):
    if doc.status != "Held":
        return
    title = f"Item on hold: {doc.item_code}"
    body = doc.reason or doc.item_code
    for shell in ("qc", "warehouse"):
        notify_shell(
            shell,
            title,
            body,
            reference_doctype="Quality Hold",
            reference_document=doc.name,
        )


def notify_overdue_tasks():
    tasks = frappe.get_all(
        "Warehouse Task",
        filters={
            "status": ["in", ["Pending", "In Progress"]],
            "docstatus": ["<", 2],
            "due_date": ["<", now_datetime()],
        },
        fields=["name", "task_type", "assigned_to", "due_date"],
    )
    warehouse_users = None
    for task in tasks:
        title = f"Task overdue: {task.name}"
        body = f"{task.task_type} was due {task.due_date}"
        if task.assigned_to:
            notify(
                task.assigned_to,
                title,
                body,
                reference_doctype="Warehouse Task",
                reference_document=task.name,
                role_shell="warehouse",
            )
            continue
        if warehouse_users is None:
            warehouse_users = users_for_shell("warehouse")
        for user in warehouse_users:
            notify(
                user,
                title,
                body,
                reference_doctype="Warehouse Task",
                reference_document=task.name,
                role_shell="warehouse",
            )


def notify_calibration_due():
    rows = frappe.get_all(
        "Calibration",
        filters={"due_date": ["<=", today()], "result": "Pending"},
        fields=["name", "asset", "asset_name", "due_date", "instrument_id"],
    )
    for row in rows:
        title = f"Calibration due: {row.instrument_id or row.asset_name or row.name}"
        body = f"{row.asset_name or row.asset} due {row.due_date}"
        notify_shell(
            "maintenance",
            title,
            body,
            reference_doctype="Calibration",
            reference_document=row.name,
        )
