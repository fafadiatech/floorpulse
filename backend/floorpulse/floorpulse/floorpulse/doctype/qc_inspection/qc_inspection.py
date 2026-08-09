import frappe
from frappe.model.document import Document


class QcInspection(Document):
    def validate(self):
        if self.defects_found and self.sample_size:
            if self.defects_found > self.sample_size:
                frappe.throw("Defects Found cannot exceed Sample Size.")
        if self.defects_found and self.defects_found > 0 and not self.result:
            frappe.msgprint("Note: Defects found — please set the inspection Result.")

    def on_submit(self):
        self.status = "Submitted"
        if not self.result:
            frappe.throw("Please set the inspection Result before submitting.")
