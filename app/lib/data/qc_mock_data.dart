import '../models/app_user.dart';
import '../models/capa.dart';
import '../models/evidence.dart';
import '../models/inspection_item.dart';
import '../models/ncr.dart';
import '../models/reading_parameter.dart';
import '../models/traceability.dart';

class QCMockData {
  // ── Users ──────────────────────────────────────────────────────────────────

  static const AppUser productionUser = AppUser(
    username: 'production',
    name: 'Ravi Kumar',
    userRole: UserRole.production,
    roleLabel: 'Production Operator',
    employeeId: 'EMP-1042',
    department: 'Assembly Line A',
    initials: 'RK',
  );

  static const AppUser qcUser = AppUser(
    username: 'qc',
    name: 'Priya Sharma',
    userRole: UserRole.qc,
    roleLabel: 'QC Inspector',
    employeeId: 'EMP-2017',
    department: 'Quality Control',
    initials: 'PS',
  );

  // ── Inspection Items ───────────────────────────────────────────────────────

  static final List<InspectionItem> inspectionItems = [
    // Incoming
    InspectionItem(
      id: 'ii-1',
      referenceNumber: 'GRN-2024-001',
      productName: 'SS316 Round Bar – 25mm',
      type: InspectionType.incoming,
      status: InspectionStatus.pending,
      dueDate: DateTime.now().add(const Duration(hours: 4)),
      assignedTo: 'Priya Sharma',
      quantity: 500,
      supplier: 'Apex Components Pvt. Ltd.',
    ),
    InspectionItem(
      id: 'ii-2',
      referenceNumber: 'GRN-2024-002',
      productName: 'Hydraulic Seal Kit – Type B',
      type: InspectionType.incoming,
      status: InspectionStatus.overdue,
      dueDate: DateTime.now().subtract(const Duration(hours: 6)),
      assignedTo: 'Priya Sharma',
      quantity: 200,
      supplier: 'Sigma Seals & Gaskets',
    ),
    InspectionItem(
      id: 'ii-3',
      referenceNumber: 'GRN-2024-003',
      productName: 'Bearing Assembly – 6205ZZ',
      type: InspectionType.incoming,
      status: InspectionStatus.inProgress,
      dueDate: DateTime.now().add(const Duration(hours: 8)),
      assignedTo: 'Priya Sharma',
      quantity: 150,
      supplier: 'Precision Bearings Ltd.',
    ),
    // In-Process
    InspectionItem(
      id: 'ii-4',
      referenceNumber: 'JC-2024-041',
      productName: 'Hydraulic Pump Body – Machined',
      type: InspectionType.inProcess,
      status: InspectionStatus.pending,
      dueDate: DateTime.now().add(const Duration(hours: 2)),
      assignedTo: 'Priya Sharma',
      quantity: 12,
      workCenter: 'Bay 2 – CNC Machining',
    ),
    InspectionItem(
      id: 'ii-5',
      referenceNumber: 'JC-2024-042',
      productName: 'Pump Shaft – Turned & Ground',
      type: InspectionType.inProcess,
      status: InspectionStatus.overdue,
      dueDate: DateTime.now().subtract(const Duration(hours: 3)),
      assignedTo: 'Priya Sharma',
      quantity: 8,
      workCenter: 'Bay 3 – Grinding Cell',
    ),
    InspectionItem(
      id: 'ii-6',
      referenceNumber: 'JC-2024-043',
      productName: 'Pump Cover Assembly',
      type: InspectionType.inProcess,
      status: InspectionStatus.pending,
      dueDate: DateTime.now().add(const Duration(hours: 5)),
      assignedTo: 'Priya Sharma',
      quantity: 15,
      workCenter: 'Bay 5 – Assembly',
    ),
    // Final
    InspectionItem(
      id: 'ii-7',
      referenceNumber: 'FI-2024-011',
      productName: 'Hydraulic Pump Assembly – HPA-2000',
      type: InspectionType.finalInspection,
      status: InspectionStatus.pending,
      dueDate: DateTime.now().add(const Duration(hours: 3)),
      assignedTo: 'Priya Sharma',
      quantity: 6,
    ),
    InspectionItem(
      id: 'ii-8',
      referenceNumber: 'FI-2024-012',
      productName: 'Control Valve Assembly – CVA-500',
      type: InspectionType.finalInspection,
      status: InspectionStatus.overdue,
      dueDate: DateTime.now().subtract(const Duration(hours: 12)),
      assignedTo: 'Priya Sharma',
      quantity: 4,
    ),
  ];

  static List<InspectionItem> get incomingItems =>
      inspectionItems.where((i) => i.type == InspectionType.incoming).toList();

  static List<InspectionItem> get inProcessItems =>
      inspectionItems.where((i) => i.type == InspectionType.inProcess).toList();

  static List<InspectionItem> get finalItems => inspectionItems
      .where((i) => i.type == InspectionType.finalInspection)
      .toList();

  // ── Reading Parameters ─────────────────────────────────────────────────────

  static const List<ReadingParameter> incomingParameters = [
    ReadingParameter(
      id: 'p1',
      name: 'Outer Diameter',
      type: ParameterType.measurement,
      nominalValue: 25.0,
      tolerancePlus: 0.05,
      toleranceMinus: 0.05,
      unit: 'mm',
    ),
    ReadingParameter(
      id: 'p2',
      name: 'Wall Thickness',
      type: ParameterType.measurement,
      nominalValue: 3.0,
      tolerancePlus: 0.02,
      toleranceMinus: 0.02,
      unit: 'mm',
    ),
    ReadingParameter(
      id: 'p3',
      name: 'Length',
      type: ParameterType.measurement,
      nominalValue: 1000.0,
      tolerancePlus: 1.0,
      toleranceMinus: 1.0,
      unit: 'mm',
    ),
    ReadingParameter(
      id: 'p4',
      name: 'Surface finish acceptable?',
      type: ParameterType.checklist,
      checkDescription: 'Inspect surface for pitting, cracks, or corrosion',
    ),
    ReadingParameter(
      id: 'p5',
      name: 'Labelling correct?',
      type: ParameterType.checklist,
      checkDescription: 'Verify heat number, grade, and supplier batch tag',
    ),
    ReadingParameter(
      id: 'p6',
      name: 'Mill certificate present?',
      type: ParameterType.checklist,
      checkDescription: 'Confirm test certificate accompanies the material',
    ),
  ];

  static const List<ReadingParameter> inProcessParameters = [
    ReadingParameter(
      id: 'q1',
      name: 'Bore Diameter',
      type: ParameterType.measurement,
      nominalValue: 18.0,
      tolerancePlus: 0.03,
      toleranceMinus: 0.0,
      unit: 'mm',
    ),
    ReadingParameter(
      id: 'q2',
      name: 'Surface Roughness (Ra)',
      type: ParameterType.measurement,
      nominalValue: 1.6,
      tolerancePlus: 0.4,
      toleranceMinus: 1.6,
      unit: 'µm',
    ),
    ReadingParameter(
      id: 'q3',
      name: 'Roundness',
      type: ParameterType.measurement,
      nominalValue: 0.0,
      tolerancePlus: 0.01,
      toleranceMinus: 0.0,
      unit: 'mm',
    ),
    ReadingParameter(
      id: 'q4',
      name: 'Burrs removed?',
      type: ParameterType.checklist,
      checkDescription: 'All machined edges deburred and chamfered',
    ),
    ReadingParameter(
      id: 'q5',
      name: 'Assembly torque verified?',
      type: ParameterType.checklist,
      checkDescription: 'Fasteners tightened to specified torque (45 Nm)',
    ),
  ];

  static const List<ReadingParameter> finalParameters = [
    ReadingParameter(
      id: 'f1',
      name: 'Pressure Test (bar)',
      type: ParameterType.measurement,
      nominalValue: 250.0,
      tolerancePlus: 0.0,
      toleranceMinus: 10.0,
      unit: 'bar',
    ),
    ReadingParameter(
      id: 'f2',
      name: 'Flow Rate',
      type: ParameterType.measurement,
      nominalValue: 45.0,
      tolerancePlus: 2.0,
      toleranceMinus: 2.0,
      unit: 'L/min',
    ),
    ReadingParameter(
      id: 'f3',
      name: 'Leak test passed?',
      type: ParameterType.checklist,
      checkDescription: 'No visible leaks at rated pressure for 5 minutes',
    ),
    ReadingParameter(
      id: 'f4',
      name: 'Nameplate attached?',
      type: ParameterType.checklist,
      checkDescription: 'Verify serial number, model, and rating plate',
    ),
    ReadingParameter(
      id: 'f5',
      name: 'Packaging condition acceptable?',
      type: ParameterType.checklist,
      checkDescription: 'Product packed per dispatch spec DS-012',
    ),
  ];

  static List<ReadingParameter> parametersFor(InspectionType type) {
    switch (type) {
      case InspectionType.incoming:
        return incomingParameters;
      case InspectionType.inProcess:
        return inProcessParameters;
      case InspectionType.finalInspection:
        return finalParameters;
    }
  }

  // ── Evidence ───────────────────────────────────────────────────────────────

  static final List<Evidence> evidence = [
    Evidence(
      id: 'ev-1',
      type: 'photo',
      label: 'Surface Defect – Unit #3',
      description: 'Pitting observed on outer surface of 3rd bar in batch',
      timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
    ),
    Evidence(
      id: 'ev-2',
      type: 'photo',
      label: 'Measurement Setup',
      description: 'Micrometer reading at mid-length of sample bar',
      timestamp: DateTime.now().subtract(const Duration(minutes: 28)),
    ),
    Evidence(
      id: 'ev-3',
      type: 'note',
      label: 'Supplier Batch Tag Verified',
      description: 'Heat No. HEAT-4421 matches mill certificate. Grade: SS316L',
      timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
    Evidence(
      id: 'ev-4',
      type: 'note',
      label: 'Dimension Out of Spec',
      description:
          'OD measured at 25.08mm on 3 units – exceeds +0.05 tolerance',
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    Evidence(
      id: 'ev-5',
      type: 'photo',
      label: 'Reference Gauge Calibration Label',
      description: 'Gauge Cal. ID: CAL-2024-089 – valid until 31 Dec 2024',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  // ── CAPAs ──────────────────────────────────────────────────────────────────

  static final CAPA capa1 = CAPA(
    capaNumber: 'CAPA-2024-001',
    rootCause:
        'Supplier process drift – coolant concentration dropped below spec, causing dimensional growth on finished bars.',
    correctiveAction:
        'Return all non-conforming bars (Lot HEAT-4421). Require 100% re-inspection on next delivery from Apex Components.',
    preventiveAction:
        'Supplier to implement daily coolant concentration checks and submit monthly SPC charts. Add incoming OD sampling to standard AQL plan.',
    owner: 'Anil Mehta (Supplier Quality)',
    dueDate: DateTime.now().add(const Duration(days: 14)),
    status: CAPAStatus.inProgress,
  );

  static final CAPA capa2 = CAPA(
    capaNumber: 'CAPA-2024-002',
    rootCause:
        'Hardness test failure due to incorrect heat treatment cycle – temperature soak time reduced by operator error.',
    correctiveAction:
        'Scrap affected batch (BT-2024-089). Re-run heat treatment with verified cycle sheet sign-off.',
    preventiveAction:
        'Introduce interlocked furnace controller that prevents cycle abort. Operator re-training on HT-SOP-007.',
    owner: 'Deepak Rao (Production)',
    dueDate: DateTime.now().subtract(const Duration(days: 3)),
    status: CAPAStatus.overdue,
  );

  // ── NCRs ───────────────────────────────────────────────────────────────────

  static final List<NCR> ncrs = [
    NCR(
      ncrNumber: 'NCR-2024-001',
      productName: 'SS316 Round Bar – 25mm',
      referenceNumber: 'GRN-2024-001',
      defectType: 'Dimensional Out-of-Spec',
      quantityRejected: 18,
      severity: NCRSeverity.critical,
      status: NCRStatus.capaRaised,
      raisedDate: DateTime.now().subtract(const Duration(days: 5)),
      raisedBy: 'Priya Sharma',
      disposition: 'Return to Supplier',
      capa: capa1,
    ),
    NCR(
      ncrNumber: 'NCR-2024-002',
      productName: 'Hydraulic Seal Kit – Type B',
      referenceNumber: 'GRN-2024-002',
      defectType: 'Surface Finish Failure',
      quantityRejected: 35,
      severity: NCRSeverity.major,
      status: NCRStatus.underReview,
      raisedDate: DateTime.now().subtract(const Duration(days: 3)),
      raisedBy: 'Priya Sharma',
      disposition: 'Rework',
    ),
    NCR(
      ncrNumber: 'NCR-2024-003',
      productName: 'Bearing Assembly – 6205ZZ',
      referenceNumber: 'GRN-2023-098',
      defectType: 'Missing / Wrong Label',
      quantityRejected: 12,
      severity: NCRSeverity.minor,
      status: NCRStatus.closed,
      raisedDate: DateTime.now().subtract(const Duration(days: 21)),
      raisedBy: 'Priya Sharma',
      disposition: 'Accept As-Is',
    ),
    NCR(
      ncrNumber: 'NCR-2024-004',
      productName: 'Pump Cover Assembly',
      referenceNumber: 'JC-2024-038',
      defectType: 'Assembly Misalignment',
      quantityRejected: 3,
      severity: NCRSeverity.major,
      status: NCRStatus.open,
      raisedDate: DateTime.now().subtract(const Duration(days: 1)),
      raisedBy: 'Priya Sharma',
      disposition: 'Rework',
    ),
    NCR(
      ncrNumber: 'NCR-2024-005',
      productName: 'Pump Shaft – Turned & Ground',
      referenceNumber: 'JC-2024-035',
      defectType: 'Hardness Out-of-Spec',
      quantityRejected: 8,
      severity: NCRSeverity.critical,
      status: NCRStatus.capaRaised,
      raisedDate: DateTime.now().subtract(const Duration(days: 8)),
      raisedBy: 'Priya Sharma',
      disposition: 'Scrap',
      capa: capa2,
    ),
  ];

  // ── Pareto ─────────────────────────────────────────────────────────────────

  static const List<Map<String, dynamic>> paretoDefects = [
    {
      'defect': 'Dimensional Out-of-Spec',
      'count': 18,
      'pct': 34.0,
      'cum': 34.0,
    },
    {'defect': 'Surface Finish Failure', 'count': 12, 'pct': 22.6, 'cum': 56.6},
    {'defect': 'Missing / Wrong Label', 'count': 9, 'pct': 17.0, 'cum': 73.6},
    {'defect': 'Assembly Misalignment', 'count': 7, 'pct': 13.2, 'cum': 86.8},
    {'defect': 'Hardness Out-of-Spec', 'count': 4, 'pct': 7.5, 'cum': 94.3},
    {'defect': 'Other', 'count': 3, 'pct': 5.7, 'cum': 100.0},
  ];

  // ── Dashboard Stats ────────────────────────────────────────────────────────

  static const Map<String, dynamic> qcDashboardStats = {
    'inspectionsToday': 14,
    'ncrsRaised': 3,
    'passRatePct': 91,
    'pendingQueue': 7,
    'rejectionPct': 9,
    'overdueCapas': 2,
  };

  // ── Traceability Tree ──────────────────────────────────────────────────────

  static const TraceabilityNode traceabilityTree = TraceabilityNode(
    id: 'BT-2024-087',
    label: 'BT-2024-087',
    type: 'product',
    detail: 'Hydraulic Pump Assembly – HPA-2000',
    children: [
      TraceabilityNode(
        id: 'RAW-SS316',
        label: 'RAW-SS316',
        type: 'material',
        detail: 'SS316 Round Bar – Apex Components Pvt. Ltd.',
        children: [
          TraceabilityNode(
            id: 'HEAT-4421',
            label: 'HEAT-4421',
            type: 'batch',
            detail: 'Mill Cert: MC-4421 | Grade: SS316L',
            children: [],
          ),
        ],
      ),
      TraceabilityNode(
        id: 'RAW-SEAL-KIT',
        label: 'RAW-SEAL-KIT',
        type: 'material',
        detail: 'Hydraulic Seal Kit – Sigma Seals & Gaskets',
        children: [],
      ),
      TraceabilityNode(
        id: 'WO-2024-001',
        label: 'WO-2024-001',
        type: 'batch',
        detail: 'Work Order – Pump Assembly Line A',
        children: [
          TraceabilityNode(
            id: 'JC-2024-041',
            label: 'JC-2024-041',
            type: 'batch',
            detail: 'Job Card – Machining (Bay 2)',
            children: [],
          ),
          TraceabilityNode(
            id: 'JC-2024-042',
            label: 'JC-2024-042',
            type: 'batch',
            detail: 'Job Card – Assembly (Bay 5)',
            children: [],
          ),
        ],
      ),
    ],
  );

  // ── Stock Ledger ───────────────────────────────────────────────────────────

  static const List<StockLedgerEntry> stockLedger = [
    StockLedgerEntry(
      date: '12 Jul 2024',
      movementType: 'GRN',
      quantity: 100.0,
      unit: 'Nos',
      balance: 100.0,
      reference: 'GRN-2024-001',
    ),
    StockLedgerEntry(
      date: '13 Jul 2024',
      movementType: 'Issue',
      quantity: -25.0,
      unit: 'Nos',
      balance: 75.0,
      reference: 'JC-2024-041',
    ),
    StockLedgerEntry(
      date: '14 Jul 2024',
      movementType: 'Issue',
      quantity: -25.0,
      unit: 'Nos',
      balance: 50.0,
      reference: 'JC-2024-042',
    ),
    StockLedgerEntry(
      date: '15 Jul 2024',
      movementType: 'Transfer',
      quantity: -10.0,
      unit: 'Nos',
      balance: 40.0,
      reference: 'TRF-2024-019',
    ),
    StockLedgerEntry(
      date: '16 Jul 2024',
      movementType: 'Adjustment',
      quantity: -3.0,
      unit: 'Nos',
      balance: 37.0,
      reference: 'ADJ-2024-005',
    ),
  ];
}
