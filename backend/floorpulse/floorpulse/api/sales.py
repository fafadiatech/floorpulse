import frappe
from frappe.utils import flt, getdate

from floorpulse.api.utils import require_permission


def _default_company():
    return frappe.defaults.get_user_default("Company") or frappe.defaults.get_global_default("company")


def _credit_limit(customer_doc, company):
    rows = customer_doc.get("credit_limits") or []
    for row in rows:
        if company and row.company == company:
            return flt(row.credit_limit)
    if rows:
        return flt(rows[0].credit_limit)
    return 0.0


def _invoice_entry(si):
    amount = flt(si.grand_total)
    if si.is_return:
        return {
            "date": str(getdate(si.posting_date)),
            "type": "Credit Note",
            "reference": si.name,
            "amount": -abs(amount),
            "creation": si.creation,
        }
    if cint_bool(getattr(si, "is_debit_note", 0)):
        return {
            "date": str(getdate(si.posting_date)),
            "type": "Debit Note",
            "reference": si.name,
            "amount": abs(amount),
            "creation": si.creation,
        }
    return {
        "date": str(getdate(si.posting_date)),
        "type": "Invoice",
        "reference": si.name,
        "amount": abs(amount),
        "creation": si.creation,
    }


def cint_bool(value):
    try:
        return int(value or 0)
    except (TypeError, ValueError):
        return 0


def _payment_entry(pe):
    amount = flt(pe.paid_amount or pe.received_amount)
    return {
        "date": str(getdate(pe.posting_date)),
        "type": "Payment",
        "reference": pe.name,
        "amount": -abs(amount),
        "creation": pe.creation,
    }


@frappe.whitelist()
def customer_ledger(customer):
    cust = frappe.get_doc("Customer", customer)
    require_permission("Customer", "read", cust)

    company = _default_company()
    si_filters = {"customer": customer, "docstatus": 1}
    if company:
        si_filters["company"] = company

    outstanding = flt(
        frappe.db.sql(
            """
            SELECT IFNULL(SUM(outstanding_amount), 0)
            FROM `tabSales Invoice`
            WHERE customer = %s AND docstatus = 1
              AND (%s IS NULL OR company = %s)
            """,
            (customer, company, company),
        )[0][0]
    )

    si_fields = ["name", "posting_date", "grand_total", "is_return", "creation"]
    if frappe.get_meta("Sales Invoice").has_field("is_debit_note"):
        si_fields.append("is_debit_note")
    invoices = frappe.get_all(
        "Sales Invoice",
        filters=si_filters,
        fields=si_fields,
        order_by="posting_date asc, creation asc",
    )

    pe_filters = {
        "party_type": "Customer",
        "party": customer,
        "docstatus": 1,
        "payment_type": "Receive",
    }
    if company:
        pe_filters["company"] = company
    payments = frappe.get_all(
        "Payment Entry",
        filters=pe_filters,
        fields=["name", "posting_date", "paid_amount", "received_amount", "creation"],
        order_by="posting_date asc, creation asc",
    )

    raw = [_invoice_entry(si) for si in invoices] + [_payment_entry(pe) for pe in payments]
    raw.sort(key=lambda row: (row["date"], row["creation"], row["reference"]))

    running = 0.0
    entries = []
    for row in raw:
        running = round(running + flt(row["amount"]), 2)
        entries.append(
            {
                "date": row["date"],
                "type": row["type"],
                "reference": row["reference"],
                "amount": flt(row["amount"]),
                "balance": running,
            }
        )

    return {
        "customer": cust.name,
        "outstanding": outstanding,
        "credit_limit": _credit_limit(cust, company),
        "payment_terms": cust.payment_terms,
        "entries": entries,
    }


def _step(doctype, name, status, date):
    return {
        "doctype": doctype,
        "name": name,
        "status": status,
        "date": str(getdate(date)) if date else None,
    }


def _work_order_steps(sales_order):
    steps = []
    for row in frappe.get_all(
        "Work Order",
        filters={"sales_order": sales_order, "docstatus": ["<", 2]},
        fields=["name", "status", "planned_start_date", "actual_start_date", "modified", "docstatus"],
        order_by="creation asc",
    ):
        date = row.actual_start_date or row.planned_start_date
        if row.docstatus == 0:
            date = None
        steps.append(_step("Work Order", row.name, row.status or "Draft", date))
    return steps


def _pick_list_names(sales_order):
    names = []
    if frappe.get_meta("Pick List").has_field("sales_order"):
        names.extend(
            frappe.get_all(
                "Pick List",
                filters={"sales_order": sales_order, "docstatus": ["<", 2]},
                pluck="name",
            )
        )
    child = "Pick List Item"
    if frappe.db.exists("DocType", child) and frappe.get_meta(child).has_field("sales_order"):
        names.extend(
            frappe.get_all(
                child,
                filters={"sales_order": sales_order},
                pluck="parent",
            )
        )
    seen = []
    for name in names:
        if name and name not in seen:
            seen.append(name)
    return seen


def _pick_list_steps(sales_order):
    steps = []
    for name in _pick_list_names(sales_order):
        if not frappe.has_permission("Pick List", "read", doc=name):
            continue
        row = frappe.db.get_value(
            "Pick List", name, ["status", "docstatus", "modified"], as_dict=True
        )
        if not row or row.docstatus == 2:
            continue
        date = None if row.docstatus == 0 else row.modified
        steps.append(_step("Pick List", name, row.status or "Draft", date))
    return steps


def _delivery_note_steps(sales_order):
    names = frappe.get_all(
        "Delivery Note Item",
        filters={"against_sales_order": sales_order},
        pluck="parent",
    )
    steps = []
    seen = set()
    for name in names:
        if not name or name in seen:
            continue
        seen.add(name)
        if not frappe.has_permission("Delivery Note", "read", doc=name):
            continue
        row = frappe.db.get_value(
            "Delivery Note",
            name,
            ["status", "docstatus", "posting_date"],
            as_dict=True,
        )
        if not row or row.docstatus == 2:
            continue
        date = None if row.docstatus == 0 else row.posting_date
        steps.append(_step("Delivery Note", name, row.status or "Draft", date))
    return steps


def _sales_invoice_names(sales_order):
    return list(
        {
            name
            for name in frappe.get_all(
                "Sales Invoice Item",
                filters={"sales_order": sales_order},
                pluck="parent",
            )
            if name
        }
    )


def _payment_entry_steps(sales_order):
    names = frappe.get_all(
        "Payment Entry Reference",
        filters={"reference_doctype": "Sales Order", "reference_name": sales_order},
        pluck="parent",
    )
    si_names = _sales_invoice_names(sales_order)
    if si_names:
        names.extend(
            frappe.get_all(
                "Payment Entry Reference",
                filters={"reference_doctype": "Sales Invoice", "reference_name": ["in", si_names]},
                pluck="parent",
            )
        )
    steps = []
    seen = set()
    for name in names:
        if not name or name in seen:
            continue
        seen.add(name)
        if not frappe.has_permission("Payment Entry", "read", doc=name):
            continue
        row = frappe.db.get_value(
            "Payment Entry",
            name,
            ["status", "docstatus", "posting_date"],
            as_dict=True,
        )
        if not row or row.docstatus == 2:
            continue
        status = "Submitted" if row.docstatus == 1 else (row.status or "Draft")
        date = None if row.docstatus == 0 else row.posting_date
        steps.append(_step("Payment Entry", name, status, date))
    return steps


@frappe.whitelist()
def fulfilment_timeline(sales_order):
    so = frappe.get_doc("Sales Order", sales_order)
    require_permission("Sales Order", "read", so)
    steps = []
    steps.extend(_work_order_steps(sales_order))
    steps.extend(_pick_list_steps(sales_order))
    steps.extend(_delivery_note_steps(sales_order))
    steps.extend(_payment_entry_steps(sales_order))
    return {"sales_order": so.name, "steps": steps}
