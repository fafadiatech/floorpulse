from frappe.model.document import Document
import frappe


class FloorPulseNotification(Document):
    def before_insert(self):
        if not self.for_user:
            self.for_user = frappe.session.user
