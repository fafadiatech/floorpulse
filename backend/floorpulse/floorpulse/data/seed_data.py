"""
Seed master and demo data for FloorPulse.

Run via:  make seed
          bench --site floorpulse.localhost execute floorpulse.data.seed_data.seed
"""
import frappe
from frappe.utils import add_days, add_months, add_to_date, now_datetime, today

from floorpulse.setup.install import _configure_system_settings


def seed():
    _configure_system_settings()
    _ensure_company()
    _ensure_uom_and_item_group()
    _seed_customers()
    _seed_warehouses()
    _seed_demo_users()
    frappe.db.commit()

    _seed_suppliers()
    _seed_items()
    _seed_assets()
    _seed_leads()
    _seed_gate_entries()
    _seed_sales_memos()
    _seed_promises_to_pay()
    _seed_vendor_scorecards()
    _seed_calibrations()
    _seed_quality_holds()
    _seed_material_returns()
    _seed_subcontract_challans()
    _seed_complaints()
    _seed_notifications()
    _seed_ncrs()
    _seed_asset_repairs()
    _seed_warehouse_tasks()
    frappe.db.commit()
    frappe.msgprint("FloorPulse seed data loaded successfully.")


def _ensure_company():
    existing = frappe.defaults.get_global_default("company") or frappe.db.get_value("Company", {}, "name")
    if existing:
        return existing
    try:
        from frappe.desk.page.setup_wizard.setup_wizard import setup_complete

        setup_complete(
            {
                "language": "English",
                "country": "India",
                "timezone": "Asia/Kolkata",
                "time_zone": "Asia/Kolkata",
                "currency": "INR",
                "full_name": "Administrator",
                "email": "admin@floorpulse.local",
                "company_name": "FloorPulse Demo",
                "company_abbr": "FPD",
                "chart_of_accounts": "Standard",
                "fy_start_date": "2026-04-01",
                "fy_end_date": "2027-03-31",
                "bank_account": "HDFC",
            }
        )
        frappe.db.commit()
    except Exception:
        frappe.db.rollback()
        frappe.logger().error("Setup wizard failed; creating Company directly")
        _try_insert(
            {
                "doctype": "Company",
                "company_name": "FloorPulse Demo",
                "abbr": "FPD",
                "default_currency": "INR",
                "country": "India",
            },
            {"company_name": "FloorPulse Demo"},
        )
    return frappe.defaults.get_global_default("company") or frappe.db.get_value("Company", {}, "name")


def _ensure_uom_and_item_group():
    if not frappe.db.exists("UOM", "Nos"):
        _try_insert({"doctype": "UOM", "uom_name": "Nos"}, {"uom_name": "Nos"})
    if not frappe.db.exists("Item Group", "All Item Groups"):
        _try_insert(
            {"doctype": "Item Group", "item_group_name": "All Item Groups", "is_group": 1},
            {"item_group_name": "All Item Groups"},
        )
    if not frappe.db.exists("Supplier Group", "All Supplier Groups"):
        _try_insert(
            {"doctype": "Supplier Group", "supplier_group_name": "All Supplier Groups", "is_group": 1},
            {"supplier_group_name": "All Supplier Groups"},
        )


def _try_insert(payload, exists_filters=None):
    doctype = payload["doctype"]
    if exists_filters:
        existing = frappe.db.exists(doctype, exists_filters)
        if existing:
            return existing
    try:
        doc = frappe.get_doc(payload)
        doc.insert(ignore_permissions=True)
        frappe.db.commit()
        return doc.name
    except Exception:
        frappe.db.rollback()
        frappe.logger().error(f"Could not create {doctype}: {exists_filters or payload}")
        return None


def _company():
    return frappe.defaults.get_global_default("company")


def _item_group():
    return (
        frappe.db.exists("Item Group", "All Item Groups")
        or frappe.db.get_value("Item Group", {"is_group": 1}, "name")
    )


def _stock_uom():
    return "Nos" if frappe.db.exists("UOM", "Nos") else frappe.db.get_value("UOM", {}, "name")


def _supplier_group():
    return (
        frappe.db.exists("Supplier Group", "All Supplier Groups")
        or frappe.db.get_value("Supplier Group", {}, "name")
    )


def _warehouse_name():
    company = _company()
    if not company:
        return None
    return _main_warehouse_name(company)


def _sales_person_name():
    return frappe.db.get_value("Sales Person", {"enabled": 1}, "name")


# ── Customers ─────────────────────────────────────────────────────────────────

CUSTOMERS = [
    {"customer_name": "Acme Corp", "customer_type": "Company", "fp_segment": "Enterprise"},
    {"customer_name": "BuildRight Ltd", "customer_type": "Company", "fp_segment": "Wholesale"},
    {"customer_name": "City Municipal Corp", "customer_type": "Company", "fp_segment": "Government"},
    {"customer_name": "Retail Outlet No. 1", "customer_type": "Company", "fp_segment": "Retail"},
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


# ── Demo users (match Flutter mock logins) ────────────────────────────────────

DEMO_USERS = [
    {
        "email": "production@floorpulse.local",
        "username": "production",
        "first_name": "Ravi",
        "last_name": "Kumar",
        "password": "prod123",
        "roles": ["Manufacturing User"],
        "gender": "Male",
        "create_sales_person": False,
        "set_default_warehouse": False,
    },
    {
        "email": "qc@floorpulse.local",
        "username": "qc",
        "first_name": "Priya",
        "last_name": "Sharma",
        "password": "qc123",
        "roles": ["Quality Manager"],
        "gender": "Female",
        "create_sales_person": False,
        "set_default_warehouse": False,
    },
    {
        "email": "warehouse@floorpulse.local",
        "username": "warehouse",
        "first_name": "Suresh",
        "last_name": "Patel",
        "password": "wh123",
        "roles": ["Stock User"],
        "gender": "Male",
        "create_sales_person": False,
        "set_default_warehouse": True,
    },
    {
        "email": "sales@floorpulse.local",
        "username": "sales",
        "first_name": "Anita",
        "last_name": "Desai",
        "password": "sales123",
        "roles": ["Sales User"],
        "gender": "Female",
        "create_sales_person": True,
        "set_default_warehouse": False,
    },
    {
        "email": "maintenance@floorpulse.local",
        "username": "maintenance",
        "first_name": "Ravi",
        "last_name": "Patil",
        "password": "maint123",
        "roles": ["Maintenance User"],
        "gender": "Male",
        "create_sales_person": False,
        "set_default_warehouse": False,
    },
]


def _main_warehouse_name(company):
    abbr = frappe.get_value("Company", company, "abbr")
    return f"Main Warehouse - {abbr}"


def _seed_demo_users():
    company = frappe.defaults.get_global_default("company")
    warehouse = _main_warehouse_name(company) if company else None

    for spec in DEMO_USERS:
        user = _ensure_user(spec)
        employee = _ensure_employee(spec, user, company) if company else None
        if employee and spec.get("create_sales_person"):
            _ensure_sales_person(employee)
        if (
            warehouse
            and spec.get("set_default_warehouse")
            and frappe.db.exists("Warehouse", warehouse)
        ):
            frappe.defaults.set_user_default("Warehouse", warehouse, user.name)
        frappe.logger().info(f"Seeded demo user: {spec['username']}")


def _ensure_user(spec):
    email = spec["email"]
    if frappe.db.exists("User", email):
        user = frappe.get_doc("User", email)
        if spec.get("username") and user.username != spec["username"]:
            user.username = spec["username"]
            user.save(ignore_permissions=True)
        user.add_roles(*spec["roles"])
        return user

    user = frappe.get_doc(
        {
            "doctype": "User",
            "email": email,
            "first_name": spec["first_name"],
            "last_name": spec["last_name"],
            "username": spec["username"],
            "send_welcome_email": 0,
            "user_type": "System User",
            "new_password": spec["password"],
        }
    )
    user.flags.ignore_password_policy = True
    user.insert(ignore_permissions=True)
    user.add_roles(*spec["roles"])
    return user


def _ensure_employee(spec, user, company):
    existing = frappe.db.get_value("Employee", {"user_id": user.name}, "name")
    if existing:
        return frappe.get_doc("Employee", existing)

    payload = {
        "doctype": "Employee",
        "first_name": spec["first_name"],
        "last_name": spec["last_name"],
        "employee_name": f"{spec['first_name']} {spec['last_name']}",
        "status": "Active",
        "company": company,
        "user_id": user.name,
        "date_of_joining": "2020-01-01",
        "date_of_birth": "1990-01-01",
        "gender": spec["gender"],
    }
    meta = frappe.get_meta("Employee")
    if meta.has_field("naming_series"):
        options = (meta.get_field("naming_series").options or "HR-EMP-").split("\n")
        payload["naming_series"] = options[0] or "HR-EMP-"

    try:
        employee = frappe.get_doc(payload)
        employee.insert(ignore_permissions=True)
        return employee
    except Exception:
        frappe.logger().error(f"Could not create Employee for {spec['username']}")
        return None


def _ensure_sales_person(employee):
    existing = frappe.db.get_value("Sales Person", {"employee": employee.name}, "name")
    if existing:
        return existing
    if frappe.db.exists("Sales Person", employee.employee_name):
        return employee.employee_name

    doc = frappe.get_doc(
        {
            "doctype": "Sales Person",
            "sales_person_name": employee.employee_name,
            "employee": employee.name,
            "enabled": 1,
        }
    )
    doc.insert(ignore_permissions=True)
    return doc.name


# ── Suppliers ─────────────────────────────────────────────────────────────────

SUPPLIERS = [
    {"supplier_name": "SteelWorks India", "supplier_type": "Company"},
    {"supplier_name": "Precision Castings Co", "supplier_type": "Company"},
    {"supplier_name": "Metro Logistics", "supplier_type": "Company"},
]


def _seed_suppliers():
    group = _supplier_group()
    for data in SUPPLIERS:
        payload = {"doctype": "Supplier", **data}
        if group:
            payload["supplier_group"] = group
        _try_insert(payload, {"supplier_name": data["supplier_name"]})


# ── Items ─────────────────────────────────────────────────────────────────────

ITEMS = [
    {"item_code": "FG-HPA-2000", "item_name": "Hydraulic Press Assembly", "is_stock_item": 1, "is_fixed_asset": 0},
    {"item_code": "FG-CVA-500", "item_name": "Control Valve Assembly", "is_stock_item": 1, "is_fixed_asset": 0},
    {"item_code": "RM-SS316-25", "item_name": "SS316 Round Bar", "is_stock_item": 1, "is_fixed_asset": 0},
    {"item_code": "SP-SEAL-KIT", "item_name": "Spare Seal Kit", "is_stock_item": 1, "is_fixed_asset": 0},
    {"item_code": "AST-HYD-PRESS", "item_name": "Hydraulic Press – Line A", "is_stock_item": 0, "is_fixed_asset": 1},
    {"item_code": "AST-AIR-COMP", "item_name": "Air Compressor – Utility", "is_stock_item": 0, "is_fixed_asset": 1},
    {"item_code": "AST-CONVEYOR", "item_name": "Conveyor System – Warehouse", "is_stock_item": 0, "is_fixed_asset": 1},
]


def _seed_items():
    group = _item_group()
    uom = _stock_uom()
    category = _ensure_asset_category()
    for data in ITEMS:
        payload = {
            "doctype": "Item",
            "item_code": data["item_code"],
            "item_name": data["item_name"],
            "is_stock_item": data["is_stock_item"],
            "is_fixed_asset": data["is_fixed_asset"],
        }
        if group:
            payload["item_group"] = group
        if uom:
            payload["stock_uom"] = uom
        if data["is_fixed_asset"] and category:
            payload["asset_category"] = category
            payload["auto_create_assets"] = 0
        _try_insert(payload, {"item_code": data["item_code"]})


def _ensure_asset_category():
    name = "Plant and Machinery"
    if frappe.db.exists("Asset Category", name):
        return name
    company = _company()
    payload = {"doctype": "Asset Category", "asset_category_name": name}
    if company:
        accounts = _asset_category_accounts(company)
        if accounts:
            payload["accounts"] = [accounts]
    return _try_insert(payload, {"asset_category_name": name}) or (
        name if frappe.db.exists("Asset Category", name) else None
    )


def _asset_category_accounts(company):
    fixed = frappe.db.get_value(
        "Account", {"company": company, "account_type": "Fixed Asset", "is_group": 0}, "name"
    )
    accum = frappe.db.get_value("Company", company, "accumulated_depreciation_account")
    expense = frappe.db.get_value("Company", company, "depreciation_expense_account")
    if not (fixed and accum and expense):
        return None
    return {
        "company_name": company,
        "fixed_asset_account": fixed,
        "accumulated_depreciation_account": accum,
        "depreciation_expense_account": expense,
    }


def _ensure_location():
    name = "Shop Floor"
    if frappe.db.exists("Location", name):
        return name
    return _try_insert({"doctype": "Location", "location_name": name}, {"location_name": name}) or name


def _seed_assets():
    company = _company()
    if not company:
        return
    location = _ensure_location()
    category = _ensure_asset_category()
    specs = [
        {"item_code": "AST-HYD-PRESS", "asset_name": "Hydraulic Press – Line A", "tag": "HP-A-01"},
        {"item_code": "AST-AIR-COMP", "asset_name": "Air Compressor – Utility Room", "tag": "AC-U-01"},
        {"item_code": "AST-CONVEYOR", "asset_name": "Conveyor System – Warehouse", "tag": "CV-W-01"},
    ]
    for spec in specs:
        if not frappe.db.exists("Item", spec["item_code"]):
            continue
        if frappe.db.exists("Asset", {"item_code": spec["item_code"], "asset_name": spec["asset_name"]}):
            continue
        payload = {
            "doctype": "Asset",
            "item_code": spec["item_code"],
            "asset_name": spec["asset_name"],
            "company": company,
            "location": location,
            "is_existing_asset": 1,
            "available_for_use_date": "2024-01-01",
            "purchase_date": "2024-01-01",
            "gross_purchase_amount": 500000,
            "fp_asset_tag": spec["tag"],
        }
        if category:
            payload["asset_category"] = category
        meta = frappe.get_meta("Asset")
        if meta.has_field("naming_series"):
            options = (meta.get_field("naming_series").options or "ACC-ASS-").split("\n")
            payload["naming_series"] = options[0] or "ACC-ASS-"
        _try_insert(payload, {"fp_asset_tag": spec["tag"]})


# ── Leads ─────────────────────────────────────────────────────────────────────

LEADS = [
    {
        "first_name": "Mohit",
        "last_name": "Agarwal",
        "company_name": "Sunrise Hydraulics Ltd.",
        "mobile_no": "+91 95555 00001",
        "city": "Pune",
        "status": "Open",
    },
    {
        "first_name": "Pallavi",
        "last_name": "Nair",
        "company_name": "FluidTech Solutions",
        "mobile_no": "+91 97777 88889",
        "city": "Hyderabad",
        "status": "Open",
    },
    {
        "first_name": "Arjun",
        "last_name": "Singh",
        "company_name": "Precision Pumps Corp.",
        "mobile_no": "+91 88800 99911",
        "city": "Delhi",
        "status": "Lead",
    },
]


def _seed_leads():
    for data in LEADS:
        payload = {"doctype": "Lead", **data}
        _try_insert(payload, {"company_name": data["company_name"], "mobile_no": data["mobile_no"]})


# ── Gate Entry ────────────────────────────────────────────────────────────────

def _seed_gate_entries():
    rows = [
        {
            "vehicle_number": "MH-04-AB-1234",
            "driver_name": "Ramesh Yadav",
            "party": "SteelWorks India",
            "purpose": "Delivery",
            "status": "Closed",
            "remarks": "Inbound RM delivery",
        },
        {
            "vehicle_number": "GJ-01-CD-7788",
            "driver_name": "Imran Shaikh",
            "party": "Acme Corp",
            "purpose": "Collection",
            "status": "Open",
        },
        {
            "vehicle_number": "MH-12-EF-4411",
            "party": "Metro Logistics",
            "purpose": "Empty Return",
            "status": "Open",
        },
    ]
    for data in rows:
        _try_insert(
            {"doctype": "Gate Entry", "entry_time": now_datetime(), **data},
            {"vehicle_number": data["vehicle_number"]},
        )


# ── Sales Memo ────────────────────────────────────────────────────────────────

def _seed_sales_memos():
    sales_person = _sales_person_name()
    rows = [
        {
            "memo_type": "Voice",
            "content": "Rajesh at Bharat Pumps mentioned they are planning to expand to a third assembly line.",
            "customer": "Acme Corp",
            "product_interest": "HPA-3000",
        },
        {
            "memo_type": "Note",
            "content": "Competitor Flowmax quoted lower on CVA-500. Follow up with volume discount.",
            "customer": "BuildRight Ltd",
            "product_interest": "FG-CVA-500",
        },
        {
            "memo_type": "Note",
            "content": "Q3 quote discussion with City Municipal Corp. Decision expected next week.",
            "customer": "City Municipal Corp",
        },
        {
            "memo_type": "Voice",
            "content": "Self-reminder: confirm HPA-3000 lead time before Friday call.",
        },
    ]
    for data in rows:
        payload = {"doctype": "Sales Memo", **data}
        if sales_person:
            payload["sales_person"] = sales_person
        if payload.get("customer") and not frappe.db.exists("Customer", payload["customer"]):
            payload.pop("customer")
        _try_insert(payload, {"content": data["content"]})


# ── Promise to Pay ────────────────────────────────────────────────────────────

def _seed_promises_to_pay():
    rows = [
        {
            "customer": "Acme Corp",
            "promise_amount": 50000,
            "expected_date": add_days(today(), 7),
            "payment_mode": "NEFT",
            "status": "Open",
            "notes": "Balance of INV-2024-201",
        },
        {
            "customer": "BuildRight Ltd",
            "promise_amount": 98500,
            "expected_date": add_days(today(), 14),
            "payment_mode": "Cheque",
            "status": "Open",
        },
        {
            "customer": "Retail Outlet No. 1",
            "promise_amount": 25000,
            "expected_date": add_days(today(), -3),
            "payment_mode": "UPI",
            "status": "Broken",
            "notes": "Missed promised date",
        },
    ]
    for data in rows:
        if not frappe.db.exists("Customer", data["customer"]):
            continue
        _try_insert(
            {"doctype": "Promise to Pay", **data},
            {"customer": data["customer"], "promise_amount": data["promise_amount"]},
        )


# ── Vendor Scorecard ──────────────────────────────────────────────────────────

def _seed_vendor_scorecards():
    rows = [
        {
            "supplier": "SteelWorks India",
            "period_from": add_months(today(), -3),
            "period_to": today(),
            "quality_score": 88,
            "delivery_score": 92,
            "overall_score": 90,
            "remarks": "On-time, minor dimensional NCRs",
        },
        {
            "supplier": "Precision Castings Co",
            "period_from": add_months(today(), -3),
            "period_to": today(),
            "quality_score": 74,
            "delivery_score": 81,
            "overall_score": 77,
            "remarks": "Surface finish issues on last two lots",
        },
    ]
    for data in rows:
        if not frappe.db.exists("Supplier", data["supplier"]):
            continue
        _try_insert({"doctype": "Vendor Scorecard", **data}, {"supplier": data["supplier"]})


# ── Calibration ───────────────────────────────────────────────────────────────

def _seed_calibrations():
    assets = frappe.get_all("Asset", fields=["name"], limit=3)
    if not assets:
        return
    specs = [
        {"due_date": add_days(today(), 14), "result": "Pending", "instrument_id": "CAL-MIC-01"},
        {"due_date": add_days(today(), -5), "result": "Pass", "calibrated_on": add_days(today(), -5), "next_due_date": add_months(today(), 12), "instrument_id": "CAL-GAUGE-02"},
        {"due_date": add_days(today(), 45), "result": "Pending", "instrument_id": "CAL-TORQUE-03"},
    ]
    for asset, spec in zip(assets, specs):
        _try_insert(
            {"doctype": "Calibration", "asset": asset.name, **spec},
            {"instrument_id": spec["instrument_id"]},
        )


# ── Quality Hold ──────────────────────────────────────────────────────────────

def _seed_quality_holds():
    warehouse = _warehouse_name()
    rows = [
        {
            "item_code": "FG-HPA-2000",
            "batch_no": "B-2024-081",
            "qty": 6,
            "reason": "Dimensional Out-of-Spec on sample",
            "status": "Held",
        },
        {
            "item_code": "FG-CVA-500",
            "batch_no": "B-2024-077",
            "qty": 3,
            "reason": "Surface finish failure — awaiting CAPA",
            "status": "Released",
            "held_on": add_to_date(now_datetime(), days=-4),
            "released_on": add_to_date(now_datetime(), days=-1),
        },
    ]
    for data in rows:
        if not frappe.db.exists("Item", data["item_code"]):
            continue
        payload = {"doctype": "Quality Hold", **data}
        if warehouse:
            payload["warehouse"] = warehouse
        _try_insert(payload, {"item_code": data["item_code"], "batch_no": data["batch_no"]})


# ── Material Return ───────────────────────────────────────────────────────────

def _seed_material_returns():
    warehouse = _warehouse_name()
    rows = [
        {
            "return_type": "Return to Store",
            "party_type": "Warehouse",
            "party": warehouse,
            "item_code": "SP-SEAL-KIT",
            "qty": 2,
            "status": "Open",
        },
        {
            "return_type": "Customer Return",
            "party_type": "Customer",
            "party": "Acme Corp",
            "item_code": "FG-CVA-500",
            "qty": 1,
            "status": "In Progress",
        },
        {
            "return_type": "Return to Supplier",
            "party_type": "Supplier",
            "party": "SteelWorks India",
            "item_code": "RM-SS316-25",
            "qty": 15,
            "status": "Open",
        },
    ]
    for data in rows:
        if data.get("item_code") and not frappe.db.exists("Item", data["item_code"]):
            continue
        if data.get("party") and data.get("party_type") and not frappe.db.exists(data["party_type"], data["party"]):
            data = {**data, "party_type": None, "party": None}
        payload = {"doctype": "Material Return", **{k: v for k, v in data.items() if v}}
        if warehouse:
            payload["warehouse"] = warehouse
        _try_insert(payload, {"return_type": data["return_type"], "item_code": data.get("item_code")})


# ── Subcontract Challan ───────────────────────────────────────────────────────

def _seed_subcontract_challans():
    rows = [
        {
            "direction": "Send",
            "supplier": "Precision Castings Co",
            "challan_date": add_days(today(), -4),
            "item_code": "RM-SS316-25",
            "qty": 40,
            "status": "Dispatched",
            "notes": "Machining subcontract",
        },
        {
            "direction": "Receive",
            "supplier": "Precision Castings Co",
            "challan_date": today(),
            "item_code": "FG-HPA-2000",
            "qty": 8,
            "status": "Open",
        },
    ]
    for data in rows:
        if not frappe.db.exists("Supplier", data["supplier"]):
            continue
        if data.get("item_code") and not frappe.db.exists("Item", data["item_code"]):
            data = {**data, "item_code": None}
        payload = {"doctype": "Subcontract Challan", **{k: v for k, v in data.items() if v is not None}}
        _try_insert(payload, {"direction": data["direction"], "challan_date": data["challan_date"]})


# ── Customer Complaint ────────────────────────────────────────────────────────

def _seed_complaints():
    rows = [
        {
            "customer": "Acme Corp",
            "subject": "Late delivery on last HPA lot",
            "complaint_date": add_days(today(), -6),
            "severity": "Medium",
            "status": "In Progress",
            "description": "Customer reported 4-day slip vs promised date.",
        },
        {
            "customer": "BuildRight Ltd",
            "subject": "Seal kit packing damage",
            "complaint_date": add_days(today(), -2),
            "severity": "Low",
            "status": "Open",
        },
        {
            "customer": "City Municipal Corp",
            "subject": "Documentation mismatch on invoice",
            "complaint_date": add_days(today(), -20),
            "severity": "High",
            "status": "Resolved",
            "resolution": "Corrected invoice reissued.",
        },
    ]
    for data in rows:
        if not frappe.db.exists("Customer", data["customer"]):
            continue
        _try_insert({"doctype": "Customer Complaint", **data}, {"subject": data["subject"]})


# ── FloorPulse Notification ───────────────────────────────────────────────────

def _seed_notifications():
    rows = [
        {"title": "Job Card JC-00012 started", "body": "Hydraulic Press job is in progress.", "for_user": "production@floorpulse.local", "role_shell": "production"},
        {"title": "NCR raised on FG-HPA-2000", "body": "Dimensional Out-of-Spec — review CAPA.", "for_user": "qc@floorpulse.local", "role_shell": "qc"},
        {"title": "GRN pending at gate", "body": "Vehicle MH-04-AB-1234 awaiting unload.", "for_user": "warehouse@floorpulse.local", "role_shell": "warehouse"},
        {"title": "PTP due this week", "body": "Acme Corp promised ₹50,000 by NEFT.", "for_user": "sales@floorpulse.local", "role_shell": "sales"},
        {"title": "Press still down", "body": "Hydraulic Press – Line A open breakdown.", "for_user": "maintenance@floorpulse.local", "role_shell": "maintenance"},
    ]
    for data in rows:
        if not frappe.db.exists("User", data["for_user"]):
            continue
        _try_insert({"doctype": "FloorPulse Notification", **data}, {"title": data["title"], "for_user": data["for_user"]})


# ── NCR (Pareto) ──────────────────────────────────────────────────────────────

NCR_DEFECTS = [
    ("Dimensional Out-of-Spec", 3),
    ("Surface Finish Failure", 2),
    ("Missing / Wrong Label", 2),
    ("Assembly Misalignment", 2),
    ("Hardness Out-of-Spec", 1),
    ("Other", 1),
]


def _seed_ncrs():
    item = "FG-HPA-2000" if frappe.db.exists("Item", "FG-HPA-2000") else frappe.db.get_value("Item", {}, "name")
    if not item:
        return
    raised_by = "qc@floorpulse.local" if frappe.db.exists("User", "qc@floorpulse.local") else frappe.session.user
    idx = 0
    for defect, count in NCR_DEFECTS:
        for _ in range(count):
            idx += 1
            _try_insert(
                {
                    "doctype": "NCR",
                    "item_code": item,
                    "raised_by": raised_by,
                    "raised_date": add_days(today(), -idx),
                    "severity": "Major" if idx % 3 else "Critical",
                    "defect_type": defect,
                    "quantity_rejected": 1 + (idx % 3),
                    "status": "Open",
                    "notes": f"Seed NCR {idx}",
                },
                {"notes": f"Seed NCR {idx}"},
            )


# ── Asset Repair (Downtime Log) ───────────────────────────────────────────────

def _seed_asset_repairs():
    assets = frappe.get_all("Asset", fields=["name", "asset_name"], limit=3)
    if not assets:
        return
    now = now_datetime()
    specs = [
        {"repair_status": "Pending", "failure_date": add_to_date(now, hours=-2), "completion_date": None, "description": "Line A hydraulic leak — currently down"},
        {"repair_status": "Pending", "failure_date": add_to_date(now, hours=-7), "completion_date": None, "description": "Compressor overheating, awaiting parts"},
        {"repair_status": "Completed", "failure_date": add_to_date(now, days=-3), "completion_date": add_to_date(now, hours=-68), "description": "Conveyor belt replaced"},
        {"repair_status": "Completed", "failure_date": add_to_date(now, days=-7), "completion_date": add_to_date(now, hours=-162), "description": "Servo drive overheating resolved"},
    ]
    for i, spec in enumerate(specs):
        asset = assets[i % len(assets)]
        payload = {
            "doctype": "Asset Repair",
            "asset": asset.name,
            "failure_date": spec["failure_date"],
            "repair_status": spec["repair_status"],
            "description": spec["description"],
        }
        if spec["completion_date"]:
            payload["completion_date"] = spec["completion_date"]
        company = _company()
        if company:
            payload["company"] = company
        _try_insert(payload, {"description": spec["description"]})


# ── Warehouse Task ────────────────────────────────────────────────────────────

def _seed_warehouse_tasks():
    warehouse = _warehouse_name()
    if not warehouse:
        return
    assigned = "warehouse@floorpulse.local" if frappe.db.exists("User", "warehouse@floorpulse.local") else None
    rows = [
        {"task_type": "GRN", "status": "Pending", "notes": "Seed GRN queue"},
        {"task_type": "Put-Away", "status": "Pending", "notes": "Seed put-away"},
        {"task_type": "Picking", "status": "In Progress", "notes": "Seed pick list"},
        {"task_type": "Returns Processing", "status": "Pending", "notes": "Seed returns processing"},
        {"task_type": "Cycle Count", "status": "Pending", "notes": "Seed cycle count"},
    ]
    for data in rows:
        payload = {
            "doctype": "Warehouse Task",
            "warehouse": warehouse,
            "due_date": add_days(now_datetime(), 1),
            **data,
        }
        if assigned:
            payload["assigned_to"] = assigned
        _try_insert(payload, {"task_type": data["task_type"], "notes": data["notes"]})
