import frappe
from frappe.model.document import Document


class WarehouseTask(Document):
    """Mobile dispatcher queue. Execution still happens on the linked ERPNext
    document (Purchase Receipt, Pick List, Stock Entry, Stock Reconciliation).
    """

    def on_submit(self):
        self.status = "Completed"
