import frappe
from frappe.model.document import Document


class NCR(Document):
    def before_insert(self):
        if not self.raised_by:
            self.raised_by = frappe.session.user

    def validate(self):
        if self.quantity_rejected is not None and self.quantity_rejected < 1:
            frappe.throw("Quantity Rejected must be at least 1.")

        has_capa = bool(self.corrective_action or self.preventive_action)
        if has_capa and self.status == "Open":
            self.status = "CAPA Raised"
        if has_capa and not self.capa_status:
            self.capa_status = "Open"

        if self.status == "Closed" and has_capa and self.capa_status not in ("Closed",):
            frappe.throw("Close the CAPA before closing this NCR.")
