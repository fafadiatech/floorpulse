import frappe
from frappe.utils import getdate, today

from floorpulse.api.auth import VALID_SHELLS, get_user_shells


TASK_KPI_MAP = {
    "GRN": "pendingGRNs",
    "Put-Away": "pendingPutAways",
    "Issue": "issueRequests",
    "Picking": "pickLists",
    "Cycle Count": "countsDue",
}

OPEN_TASK_STATUSES = ("Pending", "In Progress")


def ratio_pct(numerator, denominator, digits=1):
    if not denominator:
        return 0.0
    return round(float(numerator) / float(denominator) * 100.0, digits)


def _count(doctype, filters=None):
    return frappe.db.count(doctype, filters or {}) or 0


def _sql_value(query, values=None, default=0):
    rows = frappe.db.sql(query, values or ())
    if not rows or rows[0][0] is None:
        return default
    return rows[0][0]


def _is_system_manager(user=None):
    return "System Manager" in frappe.get_roles(user or frappe.session.user)


def _month_start(day=None):
    day = getdate(day or today())
    return day.replace(day=1)


def _stock_alert_count():
    return _sql_value(
        """
        SELECT COUNT(*)
        FROM `tabBin` bin
        INNER JOIN `tabItem Reorder` ir ON ir.parent = bin.item_code
        WHERE bin.actual_qty < IFNULL(ir.warehouse_reorder_level, 0)
          AND (ir.warehouse = bin.warehouse OR IFNULL(ir.warehouse, '') = '')
        """
    )


def production_kpis():
    produced, planned = frappe.db.sql(
        """
        SELECT IFNULL(SUM(produced_qty), 0), IFNULL(SUM(qty), 0)
        FROM `tabWork Order`
        WHERE docstatus < 2 AND status NOT IN ('Stopped', 'Closed')
        """
    )[0]
    on_time, total_dn = frappe.db.sql(
        """
        SELECT
            IFNULL(SUM(CASE WHEN dn.posting_date <= so.delivery_date THEN 1 ELSE 0 END), 0),
            COUNT(*)
        FROM `tabDelivery Note` dn
        INNER JOIN `tabDelivery Note Item` dni ON dni.parent = dn.name
        INNER JOIN `tabSales Order` so ON so.name = dni.against_sales_order
        WHERE dn.docstatus = 1
          AND dn.posting_date >= DATE_SUB(%s, INTERVAL 30 DAY)
          AND IFNULL(dni.against_sales_order, '') != ''
          AND so.delivery_date IS NOT NULL
        """,
        (today(),),
    )[0]
    return {
        "activeWorkOrders": _count(
            "Work Order",
            {"status": ["not in", ["Completed", "Stopped", "Closed"]], "docstatus": ["<", 2]},
        ),
        "completedToday": _count(
            "Work Order",
            {"status": "Completed", "modified": [">=", today()]},
        ),
        "productionEfficiency": ratio_pct(produced, planned),
        "openAlerts": _count("NCR", {"severity": "Critical", "status": ["!=", "Closed"]}),
        "pendingInspections": _count("Quality Inspection", {"docstatus": 0}),
        "onTimeDelivery": ratio_pct(on_time, total_dn),
    }


def qc_kpis():
    accepted = _count(
        "Quality Inspection",
        {"status": "Accepted", "modified": [">=", today()]},
    )
    rejected = _count(
        "Quality Inspection",
        {"status": "Rejected", "modified": [">=", today()]},
    )
    inspected = accepted + rejected
    return {
        "inspectionsToday": inspected,
        "ncrsRaised": _count("NCR", {"raised_date": today()}),
        "passRatePct": round(ratio_pct(accepted, inspected)),
        "pendingQueue": _count("Quality Inspection", {"docstatus": 0}),
        "rejectionPct": round(ratio_pct(rejected, inspected)),
        "overdueCapas": _count(
            "NCR",
            {
                "capa_status": ["in", ["Open", "In Progress"]],
                "capa_due_date": ["<", today()],
            },
        ),
    }


def warehouse_kpis():
    stats = {
        "pendingGRNs": 0,
        "pendingPutAways": 0,
        "issueRequests": 0,
        "pickLists": 0,
        "countsDue": 0,
        "stockAlerts": _stock_alert_count(),
    }
    for task_type, key in TASK_KPI_MAP.items():
        stats[key] = _count(
            "Warehouse Task",
            {
                "task_type": task_type,
                "status": ["in", list(OPEN_TASK_STATUSES)],
                "docstatus": ["<", 2],
            },
        )
    return stats


def sales_kpis():
    workflow_in_use = _sql_value(
        """
        SELECT COUNT(*) FROM `tabSales Order`
        WHERE IFNULL(workflow_state, '') != ''
        """
    )
    if workflow_in_use:
        pending_approvals = _sql_value(
            """
            SELECT COUNT(*) FROM `tabSales Order`
            WHERE docstatus = 0
              AND IFNULL(workflow_state, '') NOT IN ('', 'Approved')
            """
        )
    else:
        pending_approvals = _count("Sales Order", {"docstatus": 0, "status": "Draft"})

    collection = _sql_value(
        """
        SELECT IFNULL(SUM(paid_amount), 0)
        FROM `tabPayment Entry`
        WHERE docstatus = 1
          AND payment_type = 'Receive'
          AND posting_date >= %s
        """,
        (_month_start(),),
    )

    sales_person = None
    employee = frappe.db.get_value("Employee", {"user_id": frappe.session.user}, "name")
    if employee:
        sales_person = frappe.db.get_value("Sales Person", {"employee": employee, "enabled": 1}, "name")

    target = None
    if sales_person:
        target = _sql_value(
            """
            SELECT SUM(target_amount)
            FROM `tabTarget Detail`
            WHERE parenttype = 'Sales Person' AND parent = %s
            """,
            (sales_person,),
            default=None,
        )

    return {
        "todayVisits": _count("Customer Visit", {"visit_date": today()}),
        "pendingApprovals": pending_approvals,
        "openOrders": _count(
            "Sales Order",
            {"docstatus": 1, "status": ["not in", ["Completed", "Closed", "Cancelled"]]},
        ),
        "collectionMTD": float(collection or 0),
        "targetMTD": float(target) if target is not None else None,
    }


def maintenance_kpis():
    mttr = _sql_value(
        """
        SELECT AVG(TIMESTAMPDIFF(HOUR, failure_date, completion_date))
        FROM `tabAsset Repair`
        WHERE docstatus = 1
          AND repair_status = 'Completed'
          AND failure_date IS NOT NULL
          AND completion_date IS NOT NULL
        """,
        default=0,
    )
    return {
        "machinesDown": _count(
            "Asset Repair",
            {"repair_status": ["not in", ["Completed", "Cancelled"]], "docstatus": ["<", 2]},
        ),
        "overduePM": _count("Asset", {"fp_next_pm_date": ["<", today()]}),
        "mttr": round(float(mttr or 0), 1),
        "sparesLow": _stock_alert_count(),
    }


DASHBOARDS = {
    "production": production_kpis,
    "qc": qc_kpis,
    "warehouse": warehouse_kpis,
    "sales": sales_kpis,
    "maintenance": maintenance_kpis,
}


def resolve_dashboard_role(requested=None, user_shells=None, is_admin=False):
    if requested:
        if requested not in VALID_SHELLS:
            raise ValueError(f"Unknown dashboard role: {requested}")
        if not is_admin and requested not in (user_shells or []):
            raise PermissionError("Not permitted for this dashboard")
        return requested
    if user_shells:
        return user_shells[0]
    return None


@frappe.whitelist()
def get(role=None):
    shells = get_user_shells()
    try:
        resolved = resolve_dashboard_role(role or None, shells, _is_system_manager())
    except ValueError as exc:
        frappe.throw(str(exc))
    except PermissionError as exc:
        frappe.throw(str(exc))

    if not resolved:
        frappe.throw("No FloorPulse role on this session")

    payload = DASHBOARDS[resolved]()
    payload["role"] = resolved
    return payload
