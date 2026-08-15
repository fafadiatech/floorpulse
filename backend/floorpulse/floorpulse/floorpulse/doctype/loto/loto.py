import frappe
from frappe.model.document import Document
from frappe.utils import now_datetime


class LOTO(Document):
    def validate(self):
        if self.applied_on and self.removed_on and self.removed_on < self.applied_on:
            frappe.throw("Removed On cannot be before Applied On.")

        if self.status == "Applied" and not self.applied_on:
            self.applied_on = now_datetime()

        if self.status == "Removed":
            if not self.applied_on:
                frappe.throw("Set Applied On before marking LOTO as Removed.")
            if not self.removed_on:
                self.removed_on = now_datetime()
