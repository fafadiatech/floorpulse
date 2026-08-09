# Custom ERPNext v15 image with the floorpulse app bundled in
FROM frappe/erpnext:version-15

USER root

# Copy the floorpulse app into the bench apps directory
COPY --chown=frappe:frappe backend/floorpulse /home/frappe/frappe-bench/apps/floorpulse

USER frappe

# Install as an editable package so Frappe can discover it
RUN /home/frappe/frappe-bench/env/bin/pip install --no-cache-dir -e /home/frappe/frappe-bench/apps/floorpulse
