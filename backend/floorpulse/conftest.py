"""pytest configuration — stubs Frappe globals so unit tests run without a live bench."""
import sys
from unittest.mock import MagicMock


class FrappeTestError(Exception):
    pass


def _whitelist(*args, **kwargs):
    def decorator(fn):
        return fn

    if args and callable(args[0]) and not kwargs:
        return args[0]
    return decorator


def _throw(msg, *exc_args, **kwargs):
    raise FrappeTestError(str(msg))


frappe_mock = MagicMock()
frappe_mock.db = MagicMock()
frappe_mock.get_all = MagicMock(return_value=[])
frappe_mock.get_doc = MagicMock(return_value=MagicMock())
frappe_mock.whitelist = _whitelist
frappe_mock.throw = _throw
frappe_mock.session = MagicMock(user="Guest")
frappe_mock.PermissionError = FrappeTestError
frappe_mock.DoesNotExistError = FrappeTestError
frappe_mock.ValidationError = FrappeTestError

utils_mock = MagicMock()
utils_mock.today = MagicMock(return_value="2026-08-15")
utils_mock.getdate = MagicMock(side_effect=lambda d=None: d or "2026-08-15")
utils_mock.now_datetime = MagicMock(return_value="2026-08-15 12:00:00")
utils_mock.time_diff_in_hours = MagicMock(return_value=1.5)

sys.modules.setdefault("frappe", frappe_mock)
sys.modules.setdefault("frappe.utils", utils_mock)
sys.modules.setdefault("frappe.model.document", MagicMock())
sys.modules.setdefault("frappe.defaults", MagicMock())
