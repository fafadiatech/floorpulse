import frappe
from frappe import _
from frappe.utils import now_datetime, time_diff_in_hours


def execute(filters=None):
    filters = filters or {}
    return get_columns(), get_data(filters)


def get_columns():
    return [
        {
            "fieldname": "asset",
            "label": _("Asset"),
            "fieldtype": "Link",
            "options": "Asset",
            "width": 160,
        },
        {
            "fieldname": "asset_name",
            "label": _("Asset Name"),
            "fieldtype": "Data",
            "width": 200,
        },
        {
            "fieldname": "repair_status",
            "label": _("Status"),
            "fieldtype": "Data",
            "width": 120,
        },
        {
            "fieldname": "failure_date",
            "label": _("Failure Date"),
            "fieldtype": "Datetime",
            "width": 160,
        },
        {
            "fieldname": "completion_date",
            "label": _("Completion Date"),
            "fieldtype": "Datetime",
            "width": 160,
        },
        {
            "fieldname": "downtime_hours",
            "label": _("Downtime (Hours)"),
            "fieldtype": "Float",
            "width": 140,
        },
    ]


def get_data(filters):
    conditions = []
    values = {}
    if filters.get("from_date"):
        conditions.append("failure_date >= %(from_date)s")
        values["from_date"] = filters["from_date"]
    if filters.get("to_date"):
        conditions.append("failure_date <= %(to_date)s")
        values["to_date"] = filters["to_date"]
    if filters.get("asset"):
        conditions.append("asset = %(asset)s")
        values["asset"] = filters["asset"]

    where = f"WHERE {' AND '.join(conditions)}" if conditions else ""
    rows = frappe.db.sql(
        f"""
        SELECT name, asset, asset_name, repair_status, failure_date, completion_date
        FROM `tabAsset Repair`
        {where}
        ORDER BY failure_date DESC
        """,
        values,
        as_dict=True,
    )

    now = now_datetime()
    data = []
    for row in rows:
        end = row.completion_date or now
        hours = 0
        if row.failure_date:
            hours = time_diff_in_hours(end, row.failure_date) or 0
        data.append(
            {
                "asset": row.asset,
                "asset_name": row.asset_name,
                "repair_status": row.repair_status,
                "failure_date": row.failure_date,
                "completion_date": row.completion_date,
                "downtime_hours": round(hours, 2),
            }
        )
    return data
