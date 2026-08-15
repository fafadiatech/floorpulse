"""Frappe integration tests for FloorPulse whitelist methods.

Run via: make test-api
         bench --site floorpulse.localhost run-tests --app floorpulse --module floorpulse.api.test_api
"""
import unittest

import frappe

try:
    from frappe.tests.utils import FrappeTestCase
except ImportError:
    from frappe.tests import FrappeTestCase

from floorpulse.api.auth import get_session
from floorpulse.api.dashboard import get as dashboard_get
from floorpulse.api.maintenance import close_job
from floorpulse.api.notifications import notify
from floorpulse.api.production import complete_job, start_job
from floorpulse.api.qc import submit_inspection, traceability
from floorpulse.api.sales import customer_ledger, fulfilment_timeline
from floorpulse.api.scan import resolve as scan_resolve
from floorpulse.api.warehouse import dispatch, execute_task

QC = "qc@floorpulse.local"
WAREHOUSE = "warehouse@floorpulse.local"
SALES = "sales@floorpulse.local"
MAINT = "maintenance@floorpulse.local"
PRODUCTION = "production@floorpulse.local"


def _require_user(email):
    if not frappe.db.exists("User", email):
        raise unittest.SkipTest(f"Demo user {email} missing; run make seed")


def _item_code():
    return frappe.db.exists("Item", "FG-HPA-2000") or frappe.db.get_value(
        "Item", {"is_stock_item": 1, "is_fixed_asset": 0}, "name"
    )


def _warehouse():
    return frappe.db.get_value("Warehouse", {"is_group": 0}, "name")


def _customer():
    return frappe.db.exists("Customer", "Acme Corp") or frappe.db.get_value("Customer", {}, "name")


class TestFloorPulseAPI(FrappeTestCase):
    def tearDown(self):
        frappe.set_user("Administrator")
        super().tearDown()

    # ── Auth / dashboard / scan ───────────────────────────────────────────────

    def test_get_session_qc(self):
        _require_user(QC)
        frappe.set_user(QC)
        session = get_session()
        self.assertEqual(session["user"], QC)
        self.assertEqual(session["primary_role"], "qc")
        self.assertIn("qc", session["roles"])

    def test_dashboard_includes_unread_notifications(self):
        _require_user(QC)
        frappe.set_user(QC)
        payload = dashboard_get()
        self.assertEqual(payload["role"], "qc")
        self.assertIn("unreadNotifications", payload)
        self.assertGreaterEqual(payload["unreadNotifications"], 0)

    def test_dashboard_permission_deny_other_shell(self):
        _require_user(QC)
        frappe.set_user(QC)
        with self.assertRaises(Exception):
            dashboard_get(role="sales")

    def test_scan_resolve_ncr(self):
        _require_user(QC)
        ncr = frappe.db.get_value("NCR", {}, "name")
        if not ncr:
            raise unittest.SkipTest("No NCR in site")
        frappe.set_user(QC)
        hit = scan_resolve(ncr)
        self.assertEqual(hit["doctype"], "NCR")
        self.assertEqual(hit["name"], ncr)

    def test_scan_resolve_gate_entry_vehicle(self):
        _require_user(WAREHOUSE)
        name = frappe.db.get_value("Gate Entry", {"vehicle_number": "MH-04-AB-1234"}, "name")
        if not name:
            raise unittest.SkipTest("Seed gate entry missing")
        frappe.set_user(WAREHOUSE)
        hit = scan_resolve("MH-04-AB-1234")
        self.assertEqual(hit["doctype"], "Gate Entry")
        self.assertEqual(hit["name"], name)

    def test_scan_resolve_skips_unpermitted_hit(self):
        _require_user(SALES)
        ncr = frappe.db.get_value("NCR", {}, "name")
        if not ncr:
            raise unittest.SkipTest("No NCR in site")
        frappe.set_user(SALES)
        with self.assertRaises(Exception):
            scan_resolve(ncr)

    def test_scan_resolve_unknown_code(self):
        _require_user(QC)
        frappe.set_user(QC)
        with self.assertRaises(Exception):
            scan_resolve("NO-SUCH-CODE-XYZ")

    # ── execute_task ──────────────────────────────────────────────────────────

    def _make_task(self, task_type, assigned_to=None, reference_doctype=None, reference_document=None):
        warehouse = _warehouse()
        if not warehouse:
            raise unittest.SkipTest("No warehouse")
        doc = frappe.get_doc(
            {
                "doctype": "Warehouse Task",
                "task_type": task_type,
                "warehouse": warehouse,
                "status": "Pending",
                "assigned_to": assigned_to,
                "reference_doctype": reference_doctype,
                "reference_document": reference_document,
                "notes": "api-test-task",
            }
        )
        doc.insert()
        return doc

    def test_execute_task_assignee_deny(self):
        _require_user(WAREHOUSE)
        _require_user(QC)
        task = self._make_task("Issue", assigned_to=QC)
        frappe.set_user(WAREHOUSE)
        with self.assertRaises(Exception):
            execute_task(task.name, lines=[{"item_code": "FG-HPA-2000", "qty": 1}])
        task.reload()
        self.assertEqual(task.docstatus, 0)
        self.assertEqual(task.status, "Pending")

    def test_execute_task_grn_requires_reference(self):
        _require_user(WAREHOUSE)
        task = self._make_task("GRN", assigned_to=WAREHOUSE)
        frappe.set_user(WAREHOUSE)
        with self.assertRaises(Exception):
            execute_task(task.name, lines=[])
        task.reload()
        self.assertEqual(task.docstatus, 0)

    def test_execute_task_cycle_count_rollback(self):
        _require_user(WAREHOUSE)
        task = self._make_task("Cycle Count", assigned_to=WAREHOUSE)
        frappe.set_user(WAREHOUSE)
        with self.assertRaises(Exception):
            execute_task(task.name, lines=[{"item_code": "NO-SUCH-ITEM", "qty": 1}])
        task.reload()
        self.assertEqual(task.docstatus, 0)
        self.assertEqual(task.status, "Pending")

    # ── submit_inspection ─────────────────────────────────────────────────────

    def _make_qi(self):
        item = _item_code()
        if not item:
            raise unittest.SkipTest("No item")
        payload = {
            "doctype": "Quality Inspection",
            "inspection_type": "Incoming",
            "item_code": item,
            "sample_size": 1,
            "inspected_by": QC if frappe.db.exists("User", QC) else frappe.session.user,
            "status": "Accepted",
        }
        meta = frappe.get_meta("Quality Inspection")
        if meta.has_field("manual_inspection"):
            payload["manual_inspection"] = 1
        return frappe.get_doc(payload).insert()

    def test_submit_inspection_reject_requires_ncr(self):
        _require_user(QC)
        qi = self._make_qi()
        frappe.set_user(QC)
        with self.assertRaises(Exception):
            submit_inspection(qi.name, "Rejected")
        self.assertFalse(frappe.db.exists("NCR", {"quality_inspection": qi.name}))

    def test_submit_inspection_accepted_pass(self):
        _require_user(QC)
        qi = self._make_qi()
        frappe.set_user(QC)
        result = submit_inspection(qi.name, "Accepted", verdict="Pass")
        self.assertEqual(result["status"], "Accepted")
        self.assertEqual(result["verdict"], "Pass")
        self.assertIsNone(result["ncr"])
        qi.reload()
        self.assertEqual(qi.docstatus, 1)
        self.assertEqual(qi.fp_verdict, "Pass")

    def test_submit_inspection_conditional_accept(self):
        _require_user(QC)
        qi = self._make_qi()
        frappe.set_user(QC)
        result = submit_inspection(qi.name, "Accepted", verdict="Conditional Accept")
        self.assertEqual(result["status"], "Accepted")
        self.assertEqual(result["verdict"], "Conditional Accept")
        self.assertIsNone(result["ncr"])
        self.assertIsNone(result["hold_released"])

    def test_submit_inspection_rejected_creates_ncr(self):
        _require_user(QC)
        qi = self._make_qi()
        frappe.set_user(QC)
        result = submit_inspection(
            qi.name,
            "Rejected",
            ncr={"defect_type": "Dimensional Out-of-Spec", "quantity_rejected": 1},
            verdict="Reject",
        )
        self.assertEqual(result["status"], "Rejected")
        self.assertEqual(result["verdict"], "Reject")
        self.assertTrue(result["ncr"])
        self.assertTrue(frappe.db.exists("NCR", result["ncr"]))

    def test_submit_inspection_permission_deny(self):
        _require_user(SALES)
        qi = self._make_qi()
        frappe.set_user(SALES)
        with self.assertRaises(Exception):
            submit_inspection(qi.name, "Accepted", verdict="Pass")

    # ── production jobs ───────────────────────────────────────────────────────

    def test_start_job_missing_card(self):
        _require_user(PRODUCTION)
        frappe.set_user(PRODUCTION)
        with self.assertRaises(Exception):
            start_job("NO-SUCH-JOB-CARD")

    def test_complete_job_no_open_log(self):
        jc_name = frappe.db.get_value("Job Card", {"docstatus": 0}, "name")
        if not jc_name:
            raise unittest.SkipTest("No draft Job Card")
        _require_user(PRODUCTION)
        jc = frappe.get_doc("Job Card", jc_name)
        if any(log.from_time and not log.to_time for log in jc.time_logs):
            raise unittest.SkipTest("Job Card already has an open time log")
        frappe.set_user(PRODUCTION)
        with self.assertRaises(Exception):
            complete_job(jc_name)

    def test_start_and_complete_job(self):
        jc_name = frappe.db.get_value("Job Card", {"docstatus": 0, "status": ["in", ["Open", "Work In Progress"]]}, "name")
        if not jc_name:
            jc_name = frappe.db.get_value("Job Card", {"docstatus": 0}, "name")
        if not jc_name:
            raise unittest.SkipTest("No draft Job Card")
        _require_user(PRODUCTION)
        jc = frappe.get_doc("Job Card", jc_name)
        if any(log.from_time and not log.to_time for log in jc.time_logs):
            raise unittest.SkipTest("Job Card already started")
        frappe.set_user(PRODUCTION)
        started = start_job(jc_name)
        self.assertIn(started["status"], ("Work In Progress", "Open"))
        completed = complete_job(jc_name, completed_qty=1, submit=0)
        self.assertIsNotNone(completed["to_time"])
        jc.reload()
        self.assertEqual(jc.docstatus, 0)

    def test_complete_job_submit(self):
        jc_name = frappe.db.get_value("Job Card", {"docstatus": 0}, "name")
        if not jc_name:
            raise unittest.SkipTest("No draft Job Card")
        _require_user(PRODUCTION)
        jc = frappe.get_doc("Job Card", jc_name)
        open_logs = [log for log in jc.time_logs if log.from_time and not log.to_time]
        frappe.set_user(PRODUCTION)
        if not open_logs:
            start_job(jc_name)
        result = complete_job(jc_name, completed_qty=1, submit=1)
        jc.reload()
        self.assertEqual(jc.docstatus, 1)
        self.assertEqual(result["job_card"], jc_name)

    # ── close_job LOTO scoping ────────────────────────────────────────────────

    def test_close_job_loto_scoping(self):
        _require_user(MAINT)
        repair_name = frappe.db.get_value(
            "Asset Repair", {"docstatus": 0, "repair_status": ["!=", "Completed"]}, "name"
        )
        if not repair_name:
            raise unittest.SkipTest("No draft Asset Repair")
        repair = frappe.get_doc("Asset Repair", repair_name)
        other = frappe.get_doc(
            {
                "doctype": "LOTO",
                "asset": repair.asset,
                "status": "Applied",
                "lock_id": "TEST-OTHER",
                "reference_doctype": "Asset Repair",
                "reference_document": "NOT-THIS-REPAIR",
                "isolation_notes": "api-test-other",
            }
        ).insert()
        linked = frappe.get_doc(
            {
                "doctype": "LOTO",
                "asset": repair.asset,
                "status": "Applied",
                "lock_id": "TEST-LINKED",
                "reference_doctype": "Asset Repair",
                "reference_document": repair.name,
                "isolation_notes": "api-test-linked",
            }
        ).insert()
        empty = frappe.get_doc(
            {
                "doctype": "LOTO",
                "asset": repair.asset,
                "status": "Applied",
                "lock_id": "TEST-EMPTY",
                "isolation_notes": "api-test-empty",
            }
        ).insert()

        frappe.set_user(MAINT)
        result = close_job(repair.name)
        self.assertIn(linked.name, result["loto_removed"])
        self.assertIn(empty.name, result["loto_removed"])
        self.assertNotIn(other.name, result["loto_removed"])
        other.reload()
        self.assertEqual(other.status, "Applied")

    # ── sales / qc aggregations ───────────────────────────────────────────────

    def test_customer_ledger(self):
        _require_user(SALES)
        customer = _customer()
        if not customer:
            raise unittest.SkipTest("No customer")
        frappe.set_user(SALES)
        payload = customer_ledger(customer)
        self.assertEqual(payload["customer"], customer)
        self.assertIn("outstanding", payload)
        self.assertIn("credit_limit", payload)
        self.assertIn("entries", payload)
        self.assertIsInstance(payload["entries"], list)

    def test_customer_ledger_permission_deny(self):
        _require_user(WAREHOUSE)
        customer = _customer()
        if not customer:
            raise unittest.SkipTest("No customer")
        frappe.set_user(WAREHOUSE)
        with self.assertRaises(Exception):
            customer_ledger(customer)

    def test_fulfilment_timeline(self):
        _require_user(SALES)
        so = frappe.db.get_value("Sales Order", {}, "name")
        if not so:
            raise unittest.SkipTest("No Sales Order")
        frappe.set_user(SALES)
        payload = fulfilment_timeline(so)
        self.assertEqual(payload["sales_order"], so)
        self.assertIsInstance(payload["steps"], list)

    def test_traceability_item(self):
        _require_user(QC)
        item = _item_code()
        if not item:
            raise unittest.SkipTest("No item")
        frappe.set_user(QC)
        payload = traceability(item)
        self.assertEqual(payload["code"], item)
        self.assertEqual(payload["root"]["id"], item)
        self.assertIn(payload["root"]["type"], ("batch", "material", "product", "supplier"))
        self.assertIn("children", payload["root"])

    # ── dispatch ──────────────────────────────────────────────────────────────

    def test_dispatch_missing_dn(self):
        _require_user(WAREHOUSE)
        frappe.set_user(WAREHOUSE)
        with self.assertRaises(Exception):
            dispatch("NO-SUCH-DN", "MH-01-TEST-0001", "Test Driver")

    def test_dispatch_permission_deny(self):
        _require_user(QC)
        dn = frappe.db.get_value("Delivery Note", {"docstatus": 0}, "name")
        if not dn:
            raise unittest.SkipTest("No draft Delivery Note")
        frappe.set_user(QC)
        with self.assertRaises(Exception):
            dispatch(dn, "MH-01-TEST-0001", "Test Driver")

    def test_dispatch_submits_and_upserts_gate_entry(self):
        _require_user(WAREHOUSE)
        dn_name = frappe.db.get_value("Delivery Note", {"docstatus": 0}, "name")
        if not dn_name:
            raise unittest.SkipTest("No draft Delivery Note")
        frappe.set_user(WAREHOUSE)
        result = dispatch(dn_name, "MH-99-API-TEST", "API Driver")
        self.assertEqual(result["delivery_note"], dn_name)
        self.assertEqual(result["status"], "Submitted")
        self.assertTrue(result["gate_entry"])
        ge = frappe.get_doc("Gate Entry", result["gate_entry"])
        self.assertEqual(ge.status, "Closed")
        self.assertEqual(ge.purpose, "Delivery")
        self.assertEqual(ge.vehicle_number, "MH-99-API-TEST")

    # ── notifications ─────────────────────────────────────────────────────────

    def test_notify_inserts_and_skips_duplicate(self):
        _require_user(QC)
        title = "API test notify"
        first = notify(QC, title, "body", role_shell="qc")
        self.assertTrue(first)
        second = notify(QC, title, "body", role_shell="qc")
        self.assertIsNone(second)
