import pytest

from floorpulse.api.auth import ROLE_SHELL_MAP, shells_from_roles
from floorpulse.api.dashboard import TASK_KPI_MAP, ratio_pct, resolve_dashboard_role
from floorpulse.api.maintenance import normalize_readings, primary_reading
from floorpulse.api.production import find_open_time_log
from floorpulse.api.qc import inspection_error
from floorpulse.api.scan import SCAN_FALLBACKS, from_barcode_scan, scan_hit
from floorpulse.api.utils import ensure_dict, ensure_list, parse_json
from floorpulse.api.warehouse import apply_item_lines, task_error


class TestRoleMap:
    def test_quality_manager_is_qc_primary(self):
        assert shells_from_roles(["Quality Manager"]) == ["qc"]

    def test_stock_roles_map_to_warehouse(self):
        assert shells_from_roles(["Stock User"]) == ["warehouse"]
        assert shells_from_roles(["Stock Manager"]) == ["warehouse"]

    def test_first_match_wins_primary(self):
        shells = shells_from_roles(["Manufacturing User", "Quality Manager"])
        assert shells[0] == "qc"
        assert shells == ["qc", "production"]

    def test_unknown_roles_are_ignored(self):
        assert shells_from_roles(["System Manager", "Guest"]) == []

    def test_role_shell_map_covers_five_shells(self):
        shells = {shell for _, shell in ROLE_SHELL_MAP}
        assert shells == {"qc", "warehouse", "sales", "maintenance", "production"}


class TestDashboardHelpers:
    def test_ratio_pct(self):
        assert ratio_pct(87.5, 100) == 87.5
        assert ratio_pct(1, 0) == 0.0
        assert ratio_pct(1, 3, digits=0) == 33.0

    def test_task_kpi_keys(self):
        assert TASK_KPI_MAP["GRN"] == "pendingGRNs"
        assert TASK_KPI_MAP["Cycle Count"] == "countsDue"

    def test_resolve_dashboard_role_defaults_to_primary(self):
        assert resolve_dashboard_role(None, ["sales", "qc"]) == "sales"

    def test_resolve_dashboard_role_allows_own_shell(self):
        assert resolve_dashboard_role("qc", ["qc", "warehouse"]) == "qc"

    def test_resolve_dashboard_role_rejects_unknown(self):
        with pytest.raises(ValueError):
            resolve_dashboard_role("finance", ["qc"])

    def test_resolve_dashboard_role_rejects_other_shell(self):
        with pytest.raises(PermissionError):
            resolve_dashboard_role("sales", ["qc"])

    def test_admin_can_open_any_shell(self):
        assert resolve_dashboard_role("sales", ["qc"], is_admin=True) == "sales"


class TestScanHelpers:
    def test_barcode_prefers_serial(self):
        hit = from_barcode_scan({"serial_no": "SN-1", "batch_no": "B-1", "item_code": "ITEM"})
        assert hit["type"] == "Serial"
        assert hit["doctype"] == "Serial No"
        assert hit["name"] == "SN-1"

    def test_barcode_batch_then_item(self):
        assert from_barcode_scan({"batch_no": "B-1", "item_code": "ITEM"})["type"] == "Batch"
        assert from_barcode_scan({"item_code": "ITEM"})["type"] == "Item"

    def test_empty_barcode_is_none(self):
        assert from_barcode_scan({}) is None
        assert from_barcode_scan(None) is None

    def test_fallback_order(self):
        assert [f"{dt}.{field}" for dt, field in SCAN_FALLBACKS] == [
            "Asset.fp_asset_tag",
            "Asset.name",
            "Job Card.name",
            "Work Order.name",
            "Purchase Order.name",
            "Bin.name",
            "Warehouse Task.name",
        ]

    def test_scan_hit_shape(self):
        hit = scan_hit("Asset", "Asset", "AST-1", "Pump", {"asset_tag": "MCH-1"})
        assert hit["extra"]["asset_tag"] == "MCH-1"
        assert hit["label"] == "Pump"


class TestWarehouseHelpers:
    def test_open_task_is_ok(self):
        assert task_error("Pending", 0, "Issue", None) is None

    def test_submitted_or_terminal(self):
        assert "submitted" in task_error("Pending", 1, "GRN", "PO-1")
        assert "Completed" in task_error("Completed", 0, "GRN", "PO-1")
        assert "cancelled" in task_error("Pending", 2, "GRN", "PO-1").lower()

    def test_grn_requires_reference(self):
        assert "reference" in task_error("Pending", 0, "GRN", None)

    def test_apply_item_lines_on_dicts(self):
        items = [{"item_code": "A", "qty": 1}, {"item_code": "B", "qty": 2}]
        apply_item_lines(items, [{"item_code": "A", "qty": 9, "batch_no": "B1"}])
        assert items[0]["qty"] == 9
        assert items[0]["batch_no"] == "B1"
        assert items[1]["qty"] == 2


class TestQCHelpers:
    def test_reject_requires_ncr(self):
        assert inspection_error("Rejected", {}) 

    def test_reject_requires_defect_type(self):
        assert "defect_type" in inspection_error("Rejected", {"quantity_rejected": 1})

    def test_accept_ok(self):
        assert inspection_error("Accepted", {}) is None

    def test_bad_status(self):
        assert inspection_error("Pass", {}) 


class TestProductionHelpers:
    def test_find_open_time_log(self):
        logs = [
            {"from_time": "a", "to_time": "b"},
            {"from_time": "c", "to_time": None},
        ]
        assert find_open_time_log(logs)["from_time"] == "c"

    def test_no_open_log(self):
        assert find_open_time_log([{"from_time": "a", "to_time": "b"}]) is None
        assert find_open_time_log([]) is None


class TestMeterHelpers:
    def test_hours_is_primary(self):
        readings = normalize_readings({"Cycles": "10", "Hours": "123"})
        assert readings == {"Cycles": 10.0, "Hours": 123.0}
        assert primary_reading(readings) == 123.0

    def test_first_value_without_hours(self):
        readings = normalize_readings({"Cycles": 4})
        assert primary_reading(readings) == 4.0

    def test_empty_readings(self):
        assert primary_reading({}) is None


class TestJsonUtils:
    def test_parse_json_string(self):
        assert parse_json('{"a": 1}') == {"a": 1}
        assert parse_json("") is None
        assert parse_json(None, default={}) == {}

    def test_ensure_dict_and_list(self):
        assert ensure_dict('{"x": 1}') == {"x": 1}
        assert ensure_list("[1, 2]") == [1, 2]
        assert ensure_dict(None) == {}
        assert ensure_list(None) == []
