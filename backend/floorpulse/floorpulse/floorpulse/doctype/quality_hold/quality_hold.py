import frappe
from frappe.model.document import Document
from frappe.utils import now_datetime


class QualityHold(Document):
    def validate(self):
        if self.held_on and self.released_on and self.released_on < self.held_on:
            frappe.throw("Released On cannot be before Held On.")

        if self.status == "Held" and not self.held_on:
            self.held_on = now_datetime()

        if self.status == "Released":
            if not self.held_on:
                frappe.throw("Set Held On before marking this hold as Released.")
            if not self.released_on:
                self.released_on = now_datetime()
