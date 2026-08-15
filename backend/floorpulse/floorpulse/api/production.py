import frappe
from frappe.utils import cint, now_datetime, time_diff_in_hours

from floorpulse.api.utils import require_permission


def find_open_time_log(time_logs):
    for log in time_logs or []:
        from_time = log.get("from_time") if isinstance(log, dict) else log.from_time
        to_time = log.get("to_time") if isinstance(log, dict) else log.to_time
        if from_time and not to_time:
            return log
    return None


def _employee_for_session():
    return frappe.db.get_value("Employee", {"user_id": frappe.session.user, "status": "Active"}, "name")


@frappe.whitelist()
def start_job(job_card):
    jc = frappe.get_doc("Job Card", job_card)
    require_permission("Job Card", "write", jc)

    if jc.docstatus == 1:
        frappe.throw("Job Card is already submitted")
    if find_open_time_log(jc.time_logs):
        frappe.throw("Job already started")

    row = {"from_time": now_datetime()}
    employee = _employee_for_session()
    if employee:
        row["employee"] = employee
    jc.append("time_logs", row)

    if jc.status == "Open":
        jc.status = "Work In Progress"
    jc.save()

    return {
        "job_card": jc.name,
        "status": jc.status,
        "from_time": str(row["from_time"]),
    }


@frappe.whitelist()
def complete_job(job_card, completed_qty=None, submit=0):
    jc = frappe.get_doc("Job Card", job_card)
    require_permission("Job Card", "write", jc)

    open_log = find_open_time_log(jc.time_logs)
    if not open_log:
        frappe.throw("No open time log on this Job Card")

    to_time = now_datetime()
    open_log.to_time = to_time
    if completed_qty is not None:
        open_log.completed_qty = float(completed_qty)
    if open_log.from_time:
        open_log.time_in_mins = time_diff_in_hours(to_time, open_log.from_time) * 60

    if cint(submit):
        require_permission("Job Card", "submit", jc)

    try:
        jc.save()
        if cint(submit):
            jc.submit()
        return {
            "job_card": jc.name,
            "status": jc.status,
            "to_time": str(to_time),
            "completed_qty": open_log.completed_qty,
        }
    except Exception:
        frappe.db.rollback()
        raise
