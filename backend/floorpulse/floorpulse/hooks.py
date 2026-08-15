app_name = "floorpulse"
app_title = "FloorPulse"
app_publisher = "Fafadia Tech"
app_description = "ERPNext backend for FloorPulse — field operations platform for sales, maintenance, warehouse, and QC"
app_email = "sidharth@fafadiatech.com"
app_license = "MIT"

# Required Apps
# required_apps = ["erpnext"]

# Installation
# ------------
after_install = "floorpulse.setup.install.after_install"
after_migrate = "floorpulse.setup.install.after_migrate"

# Desk Notifications
# ------------------
# notification_config = "floorpulse.notifications.get_notification_config"

# Permissions
# -----------
# permission_query_conditions = {}
# has_permission = {}

# Document Events
# ---------------
doc_events = {
    "NCR": {
        "after_insert": "floorpulse.api.notifications.on_ncr_insert",
    },
    "Asset Repair": {
        "after_insert": "floorpulse.api.notifications.on_asset_repair_insert",
    },
    "Quality Inspection": {
        "on_submit": "floorpulse.api.notifications.on_qi_submit",
    },
    "Quality Hold": {
        "after_insert": "floorpulse.api.notifications.on_quality_hold",
    },
}

# Scheduled Tasks
# ---------------
scheduler_events = {
    "daily": [
        "floorpulse.api.notifications.notify_overdue_tasks",
        "floorpulse.api.notifications.notify_calibration_due",
    ],
}

# REST API — custom methods live in floorpulse.api.*
# --------------------------------
# override_whitelisted_methods = {}
