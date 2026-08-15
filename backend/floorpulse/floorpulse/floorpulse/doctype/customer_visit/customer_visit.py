import frappe
from frappe.model.document import Document


class CustomerVisit(Document):
    def validate(self):
        if self.check_in_time and self.check_out_time:
            if self.check_out_time < self.check_in_time:
                frappe.throw("Check-Out Time cannot be before Check-In Time.")

    def on_submit(self):
        if self.status not in ("Missed", "Cancelled"):
            self.status = "Completed"
