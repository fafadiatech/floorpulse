"""pytest configuration — stubs Frappe globals so unit tests run without a live bench."""
import sys
from unittest.mock import MagicMock

# Stub frappe so controllers can be imported without a running bench
frappe_mock = MagicMock()
frappe_mock.db = MagicMock()
frappe_mock.get_all = MagicMock(return_value=[])
frappe_mock.get_doc = MagicMock(return_value=MagicMock())
sys.modules.setdefault("frappe", frappe_mock)
sys.modules.setdefault("frappe.utils", MagicMock())
sys.modules.setdefault("frappe.model.document", MagicMock())
