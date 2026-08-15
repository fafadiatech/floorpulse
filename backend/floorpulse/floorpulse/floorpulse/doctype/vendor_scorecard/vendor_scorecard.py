import frappe
from frappe.model.document import Document


class VendorScorecard(Document):
    def validate(self):
        for field in ("quality_score", "delivery_score", "overall_score"):
            value = getattr(self, field, None)
            if value is not None and (value < 0 or value > 100):
                frappe.throw(f"{field.replace('_', ' ').title()} must be between 0 and 100.")
