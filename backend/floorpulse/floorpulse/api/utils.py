import json

import frappe


def parse_json(value, default=None):
    if value is None:
        return default
    if isinstance(value, str):
        value = value.strip()
        if not value:
            return default
        return json.loads(value)
    return value


def ensure_dict(value):
    parsed = parse_json(value, default={})
    if parsed is None:
        return {}
    if not isinstance(parsed, dict):
        frappe.throw("Expected a JSON object")
    return parsed


def ensure_list(value):
    parsed = parse_json(value, default=[])
    if parsed is None:
        return []
    if not isinstance(parsed, list):
        frappe.throw("Expected a JSON list")
    return parsed


def require_permission(doctype, ptype="read", doc=None):
    if not frappe.has_permission(doctype, ptype, doc=doc):
        frappe.throw(f"Not permitted to {ptype} {doctype}")


def as_mapping(row):
    if row is None:
        return {}
    if isinstance(row, dict):
        return row
    return row.as_dict() if hasattr(row, "as_dict") else dict(row)
