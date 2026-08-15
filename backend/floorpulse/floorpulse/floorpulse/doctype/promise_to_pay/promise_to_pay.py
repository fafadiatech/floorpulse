import frappe
from frappe.model.document import Document


class PromisetoPay(Document):
    def validate(self):
        if self.promise_amount is not None and self.promise_amount <= 0:
            frappe.throw("Promise Amount must be greater than 0.")
