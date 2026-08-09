# FloorPulse

**Field operations platform for sales, maintenance, warehouse, and quality control teams.**

FloorPulse connects your field teams to your business — in real time, on their phones, without paper or manual reporting. It runs on top of ERPNext so every field activity automatically flows into your existing ERP workflows.

---

## The Problem

Field teams — sales reps, maintenance technicians, warehouse workers, QC inspectors — generate critical business data every day. But that data lives in notebooks, WhatsApp messages, and memory. By the time it reaches the ERP, it's incomplete, delayed, or lost entirely.

FloorPulse puts the right form in the right person's hands at the right moment, and writes the result directly into the system of record.

---

## What FloorPulse Does

### Sales — Site Visit Tracking
Sales reps check in at customer sites from their phone. Every visit is logged with GPS co-ordinates, visit purpose, and outcome. Visit records link directly to Sales Orders, giving managers accurate territory coverage and activity data without chasing reps for reports.

### Maintenance — Digital Job Cards
Technicians receive job assignments on their phones. Each job captures the asset, problem description, work performed, and a signed-off checklist before the technician can close it out. PM schedules and meter readings stay current automatically — no backlog of paper job cards to transcribe.

### Warehouse — Mobile Task Queue
Warehouse workers pick tasks from a queue: GRN, put-away, picking, cycle count, or returns. Each task links to its source document (Purchase Receipt, Sales Order, etc.) and tracks bin-level movements, giving supervisors live visibility without paper-based handoffs or end-of-shift reconciliation.

### Quality Control — Inspection Logs
QC inspectors log pass/fail results against incoming stock or finished goods directly on their device. Each inspection records sample size, defect count, and a description, creating an auditable quality trail that feeds into supplier scorecards over time.

---

## Screenshots

### Sales — Site Visit Tracking

<table>
  <tr>
    <td><img src="app/screenshots/01.png" width="180"/></td>
    <td><img src="app/screenshots/02.png" width="180"/></td>
    <td><img src="app/screenshots/03.png" width="180"/></td>
  </tr>
  <tr>
    <td><img src="app/screenshots/04.png" width="180"/></td>
    <td><img src="app/screenshots/05.png" width="180"/></td>
    <td><img src="app/screenshots/06.png" width="180"/></td>
  </tr>
</table>

### Production

<table>
  <tr>
    <td><img src="app/screenshots/07.png" width="180"/></td>
    <td><img src="app/screenshots/08.png" width="180"/></td>
    <td><img src="app/screenshots/09.png" width="180"/></td>
  </tr>
  <tr>
    <td><img src="app/screenshots/10.png" width="180"/></td>
    <td><img src="app/screenshots/11.png" width="180"/></td>
    <td><img src="app/screenshots/12.png" width="180"/></td>
  </tr>
  <tr>
    <td><img src="app/screenshots/13.png" width="180"/></td>
    <td></td>
    <td></td>
  </tr>
</table>

### Quality Control — Inspection Logs

<table>
  <tr>
    <td><img src="app/screenshots/14.png" width="180"/></td>
    <td><img src="app/screenshots/15.png" width="180"/></td>
    <td><img src="app/screenshots/16.png" width="180"/></td>
  </tr>
  <tr>
    <td><img src="app/screenshots/17.png" width="180"/></td>
    <td><img src="app/screenshots/18.png" width="180"/></td>
    <td></td>
  </tr>
</table>

### Warehouse — Mobile Task Queue

<table>
  <tr>
    <td><img src="app/screenshots/19.png" width="180"/></td>
    <td><img src="app/screenshots/20.png" width="180"/></td>
    <td><img src="app/screenshots/21.png" width="180"/></td>
  </tr>
  <tr>
    <td><img src="app/screenshots/22.png" width="180"/></td>
    <td><img src="app/screenshots/23.png" width="180"/></td>
    <td><img src="app/screenshots/24.png" width="180"/></td>
  </tr>
</table>

### Maintenance — Digital Job Cards

<table>
  <tr>
    <td><img src="app/screenshots/25.png" width="180"/></td>
    <td><img src="app/screenshots/26.png" width="180"/></td>
    <td><img src="app/screenshots/27.png" width="180"/></td>
  </tr>
  <tr>
    <td><img src="app/screenshots/28.png" width="180"/></td>
    <td><img src="app/screenshots/29.png" width="180"/></td>
    <td><img src="app/screenshots/30.png" width="180"/></td>
  </tr>
</table>

---

## Key Benefits

| | |
|---|---|
| **Mobile-first** | Works on any Android or iOS device — no laptop required in the field |
| **ERP-native** | Built on ERPNext; all data lives in your existing system, no sync required |
| **Real-time visibility** | Supervisors see field activity as it happens, not at end of shift |
| **Auditable records** | Every visit, job, task, and inspection is timestamped and traceable |
| **Offline-capable** | Field teams can work without a data connection and sync when back online |

---

## Built On

FloorPulse runs on [ERPNext](https://erpnext.com/) v15 and [Frappe](https://frappeframework.com/) v15 — battle-tested open-source ERP with built-in financials, inventory, HR, and CRM. The mobile front-end is a Flutter app (iOS + Android). The field-operations layer is a Frappe custom app that extends ERPNext rather than replacing it.

---

## License

MIT
