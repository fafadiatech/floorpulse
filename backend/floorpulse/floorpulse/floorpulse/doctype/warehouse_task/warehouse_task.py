import frappe
from frappe.model.document import Document


class WarehouseTask(Document):
    def on_submit(self):
        self.status = "Completed"
