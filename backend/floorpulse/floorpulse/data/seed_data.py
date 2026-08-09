"""
Seed master and demo data for FloorPulse.

Run via:  make seed
          bench --site floorpulse.localhost execute floorpulse.data.seed_data.seed
"""
import frappe


def seed():
    _seed_customers()
    _seed_warehouses()
    frappe.db.commit()
    frappe.msgprint("FloorPulse seed data loaded successfully.")


# ── Customers ─────────────────────────────────────────────────────────────────

CUSTOMERS = [
    {"customer_name": "Acme Corp", "customer_type": "Company", "fp_segment": "Enterprise", "fp_credit_limit": 500000, "fp_payment_terms": 30},
    {"customer_name": "BuildRight Ltd", "customer_type": "Company", "fp_segment": "Wholesale", "fp_credit_limit": 200000, "fp_payment_terms": 45},
    {"customer_name": "City Municipal Corp", "customer_type": "Company", "fp_segment": "Government", "fp_credit_limit": 1000000, "fp_payment_terms": 60},
    {"customer_name": "Retail Outlet No. 1", "customer_type": "Company", "fp_segment": "Retail", "fp_credit_limit": 50000, "fp_payment_terms": 15},
]


def _seed_customers():
    for data in CUSTOMERS:
        if frappe.db.exists("Customer", data["customer_name"]):
            continue
        doc = frappe.get_doc({"doctype": "Customer", **data})
        doc.insert(ignore_permissions=True)
        frappe.logger().info(f"Created customer: {data['customer_name']}")


# ── Warehouses ────────────────────────────────────────────────────────────────

WAREHOUSES = [
    {"warehouse_name": "Main Warehouse", "company": frappe.defaults.get_global_default("company") if frappe.defaults else None},
    {"warehouse_name": "Returns Bay", "company": frappe.defaults.get_global_default("company") if frappe.defaults else None},
]


def _seed_warehouses():
    company = frappe.defaults.get_global_default("company")
    if not company:
        return
    for data in WAREHOUSES:
        full_name = f"{data['warehouse_name']} - {frappe.get_value('Company', company, 'abbr')}"
        if frappe.db.exists("Warehouse", full_name):
            continue
        doc = frappe.get_doc({"doctype": "Warehouse", "warehouse_name": data["warehouse_name"], "company": company})
        doc.insert(ignore_permissions=True)
        frappe.logger().info(f"Created warehouse: {data['warehouse_name']}")
