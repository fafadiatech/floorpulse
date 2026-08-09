# FloorPulse — Developer Notes

Implementation details, local setup, and API reference for contributors.

---

## Repository Layout

```
floorpulse/
├── app/                    # Flutter mobile app (iOS + Android)
├── backend/
│   └── floorpulse/         # ERPNext custom app (Python / Frappe)
│       ├── setup.py
│       └── floorpulse/
│           ├── hooks.py
│           ├── setup/install.py    # after_install / after_migrate hooks
│           ├── data/seed_data.py   # Demo data seeder
│           └── floorpulse/         # Main Frappe module
│               ├── workspace/      # FloorPulse workspace definition
│               └── doctype/        # Custom DocTypes
│                   ├── customer_visit/
│                   ├── maintenance_job/
│                   ├── warehouse_task/
│                   └── qc_inspection/
├── Dockerfile
├── docker-compose.yml
├── Makefile
└── .env.example
```

---

## Custom DocTypes

| DocType | Module | Purpose |
|---|---|---|
| **Customer Visit** | Sales | Check-in/out, visit purpose, GPS co-ordinates, outcome |
| **Maintenance Job** | Maintenance | Job card: asset, technician, checklist, sign-off |
| **Warehouse Task** | Warehouse | GRN / put-away / picking / cycle count task queue |
| **QC Inspection** | Quality | Pass/fail inspection with defect tracking |

Custom fields are also added to standard ERPNext DocTypes (Customer, Sales Order, Maintenance Visit, Asset, Purchase Receipt) to carry FloorPulse-specific data through existing workflows.

---

## Local Setup

### Prerequisites

- Docker Desktop v4.x or later
- `make`
- Port 8080 available on localhost

### First-time setup

```bash
# 1. Copy and edit environment file
cp .env.example .env
# Edit .env — change DB_PASSWORD and ADMIN_PASSWORD at minimum

# 2. Add site to /etc/hosts
echo "127.0.0.1  floorpulse.localhost" | sudo tee -a /etc/hosts

# 3. Build image, start services, create site, and seed demo data
make install
```

The ERPNext web UI will be available at `http://floorpulse.localhost:8080`.  
Login: `Administrator` / the `ADMIN_PASSWORD` you set in `.env`.

---

## Daily Commands

| Command | What it does |
|---|---|
| `make start` | Start all services |
| `make stop` | Stop all services |
| `make restart` | Restart all services |
| `make logs` | Tail logs from all containers |
| `make shell` | Open a bash shell in the backend container |
| `make bench CMD="list-apps"` | Run any `bench` command |
| `make migrate` | Apply schema changes and patches |
| `make seed` | Re-seed demo data (idempotent) |
| `make test` | Run unit tests |

---

## Danger Zone

```bash
make reset-site   # Drop & recreate the ERPNext site (data loss)
make nuke         # Remove all containers and Docker volumes (full reset)
```

Both commands prompt for confirmation before executing.

---

## REST API

The mobile app communicates with the backend through Frappe's built-in REST API. All custom DocTypes are accessible via this standard pattern with no additional configuration.

```bash
# Authenticate
POST /api/method/login
{"usr": "user@example.com", "pwd": "password"}

# List Customer Visits
GET /api/resource/Customer Visit?filters=[["status","=","Completed"]]

# Create a new Customer Visit
POST /api/resource/Customer Visit
Content-Type: application/json
{"customer": "Acme Corp", "sales_person": "...", "visit_date": "2024-06-01", ...}
```

The same pattern applies to `Maintenance Job`, `Warehouse Task`, and `QC Inspection` — substitute the DocType name in the URL.
