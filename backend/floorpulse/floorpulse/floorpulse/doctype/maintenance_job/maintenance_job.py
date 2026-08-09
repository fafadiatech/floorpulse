import frappe
from frappe.model.document import Document
from frappe.utils import now_datetime


class MaintenanceJob(Document):
    def validate(self):
        if self.completion_date and self.scheduled_date:
            if self.completion_date < self.scheduled_date:
                frappe.throw("Completion Date cannot be before Scheduled Date.")

    def on_submit(self):
        if not self.checklist_completed:
            frappe.throw("Please confirm checklist is completed before submitting.")
        self.status = "Completed"
        if not self.completion_date:
            self.completion_date = now_datetime()
