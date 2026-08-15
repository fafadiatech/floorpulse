import frappe
from frappe import _


def execute(filters=None):
    filters = filters or {}
    return get_columns(), get_data(filters)


def get_columns():
    return [
        {
            "fieldname": "defect",
            "label": _("Defect"),
            "fieldtype": "Data",
            "width": 220,
        },
        {
            "fieldname": "count",
            "label": _("Count"),
            "fieldtype": "Int",
            "width": 100,
        },
        {
            "fieldname": "pct",
            "label": _("%"),
            "fieldtype": "Percent",
            "width": 100,
        },
        {
            "fieldname": "cum",
            "label": _("Cumulative %"),
            "fieldtype": "Percent",
            "width": 120,
        },
    ]


def get_data(filters):
    conditions = []
    values = {}
    if filters.get("from_date"):
        conditions.append("raised_date >= %(from_date)s")
        values["from_date"] = filters["from_date"]
    if filters.get("to_date"):
        conditions.append("raised_date <= %(to_date)s")
        values["to_date"] = filters["to_date"]

    where = f"WHERE {' AND '.join(conditions)}" if conditions else ""
    rows = frappe.db.sql(
        f"""
        SELECT defect_type AS defect, COUNT(*) AS count
        FROM `tabNCR`
        {where}
        GROUP BY defect_type
        ORDER BY count DESC
        """,
        values,
        as_dict=True,
    )

    total = sum(row.count for row in rows) or 0
    cumulative = 0
    data = []
    for row in rows:
        pct = (row.count / total * 100) if total else 0
        cumulative += pct
        data.append(
            {
                "defect": row.defect,
                "count": row.count,
                "pct": round(pct, 1),
                "cum": round(cumulative, 1),
            }
        )
    return data
