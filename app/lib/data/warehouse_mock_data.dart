import '../models/app_user.dart';
import '../models/purchase_order.dart';
import '../models/warehouse_bin.dart';
import '../models/warehouse_task.dart';
import '../models/stock_item.dart';
import '../models/traceability.dart';

class WarehouseMockData {
  // ── User ────────────────────────────────────────────────────────────────────

  static const AppUser warehouseUser = AppUser(
    username: 'warehouse',
    name: 'Suresh Patel',
    userRole: UserRole.warehouse,
    roleLabel: 'Warehouse Operator',
    employeeId: 'EMP-3024',
    department: 'Stores & Logistics',
    initials: 'SP',
  );

  // ── Dashboard Stats ──────────────────────────────────────────────────────────

  static const Map<String, dynamic> dashboardStats = {
    'pendingGRNs': 4,
    'pendingPutAways': 7,
    'issueRequests': 3,
    'pickLists': 2,
    'countsDue': 5,
    'stockAlerts': 2,
  };

  // ── Purchase Orders ──────────────────────────────────────────────────────────

  static final List<PurchaseOrder> purchaseOrders = [
    PurchaseOrder(
      poNumber: 'PO-2024-041',
      supplier: 'Apex Components Pvt. Ltd.',
      expectedDate: DateTime.now().subtract(const Duration(hours: 2)),
      status: POStatus.pending,
      buyerContact: 'Ramesh Iyer',
      lines: [
        POLine(
          lineNo: '001',
          itemCode: 'RM-SS316-25',
          description: 'SS316 Round Bar 25mm',
          orderedQty: 500,
          unit: 'Nos',
        ),
        POLine(
          lineNo: '002',
          itemCode: 'RM-SS316-50',
          description: 'SS316 Round Bar 50mm',
          orderedQty: 200,
          unit: 'Nos',
        ),
        POLine(
          lineNo: '003',
          itemCode: 'RM-BOLT-M12',
          description: 'M12 Hex Bolt Grade 8.8',
          orderedQty: 1000,
          unit: 'Nos',
        ),
      ],
    ),
    PurchaseOrder(
      poNumber: 'PO-2024-039',
      supplier: 'Sigma Seals & Gaskets',
      expectedDate: DateTime.now().add(const Duration(hours: 4)),
      status: POStatus.partialGRN,
      buyerContact: 'Kavita Nair',
      lines: [
        POLine(
          lineNo: '001',
          itemCode: 'RM-SEAL-B',
          description: 'Hydraulic Seal Kit – Type B',
          orderedQty: 200,
          unit: 'Kits',
          receivedQty: 80,
        ),
        POLine(
          lineNo: '002',
          itemCode: 'RM-GASKET-G1',
          description: 'Gasket G1 – Compressed Fiber',
          orderedQty: 500,
          unit: 'Nos',
        ),
      ],
    ),
    PurchaseOrder(
      poNumber: 'PO-2024-038',
      supplier: 'Precision Bearings Ltd.',
      expectedDate: DateTime.now().subtract(const Duration(hours: 8)),
      status: POStatus.pending,
      buyerContact: 'Deepak Rao',
      lines: [
        POLine(
          lineNo: '001',
          itemCode: 'RM-BRG-6205',
          description: 'Bearing 6205ZZ Deep Groove',
          orderedQty: 150,
          unit: 'Nos',
        ),
        POLine(
          lineNo: '002',
          itemCode: 'RM-BRG-6306',
          description: 'Bearing 6306ZZ Deep Groove',
          orderedQty: 100,
          unit: 'Nos',
        ),
      ],
    ),
    PurchaseOrder(
      poNumber: 'PO-2024-037',
      supplier: 'National Fasteners Co.',
      expectedDate: DateTime.now().subtract(const Duration(days: 1)),
      status: POStatus.pending,
      buyerContact: 'Anita Sharma',
      lines: [
        POLine(
          lineNo: '001',
          itemCode: 'RM-NUT-M12',
          description: 'M12 Hex Nut Grade 8',
          orderedQty: 2000,
          unit: 'Nos',
        ),
        POLine(
          lineNo: '002',
          itemCode: 'RM-WASHER-M12',
          description: 'M12 Spring Washer',
          orderedQty: 2000,
          unit: 'Nos',
        ),
      ],
    ),
  ];

  // ── Tasks ────────────────────────────────────────────────────────────────────

  static final List<WarehouseTask> tasks = [
    WarehouseTask(
      id: 't1',
      type: WarehouseTaskType.grn,
      status: WarehouseTaskStatus.overdue,
      referenceNumber: 'PO-2024-037',
      description: 'GRN – National Fasteners Co.',
      detail: '2 items · 4,000 Nos',
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      itemCount: 2,
    ),
    WarehouseTask(
      id: 't2',
      type: WarehouseTaskType.grn,
      status: WarehouseTaskStatus.pending,
      referenceNumber: 'PO-2024-041',
      description: 'GRN – Apex Components',
      detail: '3 items · 1,700 Nos',
      dueDate: DateTime.now().subtract(const Duration(hours: 2)),
      itemCount: 3,
    ),
    WarehouseTask(
      id: 't3',
      type: WarehouseTaskType.putAway,
      status: WarehouseTaskStatus.pending,
      referenceNumber: 'GRN-2024-088',
      description: 'Put-away – SS316 Round Bar',
      detail: 'Zone A · 3 pallets',
      dueDate: DateTime.now().add(const Duration(hours: 1)),
      itemCount: 3,
    ),
    WarehouseTask(
      id: 't4',
      type: WarehouseTaskType.putAway,
      status: WarehouseTaskStatus.pending,
      referenceNumber: 'GRN-2024-087',
      description: 'Put-away – Bearing Assemblies',
      detail: 'Zone A · 2 bins',
      dueDate: DateTime.now().add(const Duration(hours: 2)),
      itemCount: 2,
    ),
    WarehouseTask(
      id: 't5',
      type: WarehouseTaskType.issue,
      status: WarehouseTaskStatus.pending,
      referenceNumber: 'MR-2024-112',
      description: 'Issue – Pump Assembly Line A',
      detail: 'WO-2024-041 · 4 items',
      dueDate: DateTime.now().add(const Duration(minutes: 30)),
      itemCount: 4,
    ),
    WarehouseTask(
      id: 't6',
      type: WarehouseTaskType.issue,
      status: WarehouseTaskStatus.overdue,
      referenceNumber: 'MR-2024-110',
      description: 'Issue – Machining Bay 2',
      detail: 'WO-2024-038 · 2 items',
      dueDate: DateTime.now().subtract(const Duration(hours: 3)),
      itemCount: 2,
    ),
    WarehouseTask(
      id: 't7',
      type: WarehouseTaskType.pick,
      status: WarehouseTaskStatus.pending,
      referenceNumber: 'PL-2024-019',
      description: 'Pick – Dispatch Order DO-089',
      detail: '5 lines · Customer: Bharat Pumps',
      dueDate: DateTime.now().add(const Duration(hours: 3)),
      itemCount: 5,
    ),
    WarehouseTask(
      id: 't8',
      type: WarehouseTaskType.pick,
      status: WarehouseTaskStatus.inProgress,
      referenceNumber: 'PL-2024-018',
      description: 'Pick – Dispatch Order DO-088',
      detail: '3 lines · Customer: Hydro Systems Ltd.',
      dueDate: DateTime.now().add(const Duration(hours: 5)),
      itemCount: 3,
    ),
    WarehouseTask(
      id: 't9',
      type: WarehouseTaskType.cycleCount,
      status: WarehouseTaskStatus.pending,
      referenceNumber: 'CC-2024-015',
      description: 'Cycle Count – Zone A Raw Materials',
      detail: 'A-01-03, A-02-01, A-03-02',
      dueDate: DateTime.now().add(const Duration(hours: 6)),
      itemCount: 5,
    ),
    WarehouseTask(
      id: 't10',
      type: WarehouseTaskType.cycleCount,
      status: WarehouseTaskStatus.overdue,
      referenceNumber: 'CC-2024-014',
      description: 'Cycle Count – Zone C Finished Goods',
      detail: 'C-01-01, C-01-02',
      dueDate: DateTime.now().subtract(const Duration(hours: 12)),
      itemCount: 2,
    ),
  ];

  // ── Put-away Items ───────────────────────────────────────────────────────────

  static final List<Map<String, dynamic>> putAwayItems = [
    {
      'id': 'pa1',
      'grnRef': 'GRN-2024-088',
      'itemCode': 'RM-SS316-25',
      'description': 'SS316 Round Bar 25mm',
      'qty': 500.0,
      'unit': 'Nos',
      'batch': 'BT-2024-090',
      'suggestedBin': 'A-01-03',
      'zone': 'Zone A – Raw Materials',
    },
    {
      'id': 'pa2',
      'grnRef': 'GRN-2024-088',
      'itemCode': 'RM-SS316-50',
      'description': 'SS316 Round Bar 50mm',
      'qty': 200.0,
      'unit': 'Nos',
      'batch': 'BT-2024-091',
      'suggestedBin': 'A-01-04',
      'zone': 'Zone A – Raw Materials',
    },
    {
      'id': 'pa3',
      'grnRef': 'GRN-2024-087',
      'itemCode': 'RM-BRG-6205',
      'description': 'Bearing 6205ZZ Deep Groove',
      'qty': 150.0,
      'unit': 'Nos',
      'batch': 'BT-2024-089',
      'suggestedBin': 'A-02-01',
      'zone': 'Zone A – Raw Materials',
    },
    {
      'id': 'pa4',
      'grnRef': 'GRN-2024-087',
      'itemCode': 'RM-SEAL-B',
      'description': 'Hydraulic Seal Kit – Type B',
      'qty': 80.0,
      'unit': 'Kits',
      'batch': 'BT-2024-092',
      'suggestedBin': 'A-03-02',
      'zone': 'Zone A – Raw Materials',
    },
  ];

  // ── Issue Requests ───────────────────────────────────────────────────────────

  static final List<Map<String, dynamic>> issueRequests = [
    {
      'id': 'mr1',
      'mrNumber': 'MR-2024-112',
      'woNumber': 'WO-2024-041',
      'workCenter': 'Bay 5 – Assembly',
      'requestedBy': 'Ravi Kumar',
      'status': 'Pending',
      'lines': [
        {
          'itemCode': 'RM-SS316-25',
          'description': 'SS316 Round Bar 25mm',
          'reqQty': 12.0,
          'unit': 'Nos',
          'bin': 'A-01-03',
          'batch': 'BT-2024-087',
        },
        {
          'itemCode': 'RM-SEAL-B',
          'description': 'Hydraulic Seal Kit – Type B',
          'reqQty': 6.0,
          'unit': 'Kits',
          'bin': 'A-03-02',
          'batch': 'BT-2024-092',
        },
        {
          'itemCode': 'RM-BRG-6205',
          'description': 'Bearing 6205ZZ',
          'reqQty': 8.0,
          'unit': 'Nos',
          'bin': 'A-02-01',
          'batch': 'BT-2024-089',
        },
        {
          'itemCode': 'RM-BOLT-M12',
          'description': 'M12 Hex Bolt Grade 8.8',
          'reqQty': 48.0,
          'unit': 'Nos',
          'bin': 'A-04-01',
          'batch': 'BT-2024-085',
        },
      ],
    },
    {
      'id': 'mr2',
      'mrNumber': 'MR-2024-110',
      'woNumber': 'WO-2024-038',
      'workCenter': 'Bay 2 – CNC Machining',
      'requestedBy': 'Kiran Desai',
      'status': 'Overdue',
      'lines': [
        {
          'itemCode': 'RM-SS316-50',
          'description': 'SS316 Round Bar 50mm',
          'reqQty': 10.0,
          'unit': 'Nos',
          'bin': 'A-01-04',
          'batch': 'BT-2024-091',
        },
        {
          'itemCode': 'RM-BRG-6306',
          'description': 'Bearing 6306ZZ',
          'reqQty': 4.0,
          'unit': 'Nos',
          'bin': 'A-02-02',
          'batch': 'BT-2024-086',
        },
      ],
    },
    {
      'id': 'mr3',
      'mrNumber': 'MR-2024-108',
      'woNumber': 'WO-2024-035',
      'workCenter': 'Bay 3 – Grinding',
      'requestedBy': 'Ravi Kumar',
      'status': 'Pending',
      'lines': [
        {
          'itemCode': 'RM-GASKET-G1',
          'description': 'Gasket G1 – Compressed Fiber',
          'reqQty': 20.0,
          'unit': 'Nos',
          'bin': 'A-03-01',
          'batch': 'BT-2024-083',
        },
        {
          'itemCode': 'RM-NUT-M12',
          'description': 'M12 Hex Nut Grade 8',
          'reqQty': 96.0,
          'unit': 'Nos',
          'bin': 'A-04-02',
          'batch': 'BT-2024-084',
        },
      ],
    },
  ];

  // ── Pick Lists ───────────────────────────────────────────────────────────────

  static final List<Map<String, dynamic>> pickLists = [
    {
      'id': 'pl1',
      'plNumber': 'PL-2024-019',
      'doNumber': 'DO-2024-089',
      'customer': 'Bharat Pumps & Valves',
      'dispatchDate': DateTime.now().add(const Duration(hours: 3)),
      'status': 'Pending',
      'pickedLines': 0,
      'lines': [
        {
          'lineNo': '1',
          'itemCode': 'FG-HPA-2000',
          'description': 'Hydraulic Pump Assembly HPA-2000',
          'qty': 3.0,
          'unit': 'Nos',
          'bin': 'C-01-01',
          'picked': false,
        },
        {
          'lineNo': '2',
          'itemCode': 'FG-CVA-500',
          'description': 'Control Valve Assembly CVA-500',
          'qty': 2.0,
          'unit': 'Nos',
          'bin': 'C-01-02',
          'picked': false,
        },
        {
          'lineNo': '3',
          'itemCode': 'SP-SEAL-KIT',
          'description': 'Spare Seal Kit',
          'qty': 6.0,
          'unit': 'Kits',
          'bin': 'C-02-01',
          'picked': false,
        },
        {
          'lineNo': '4',
          'itemCode': 'SP-FILTER',
          'description': 'Return Line Filter',
          'qty': 3.0,
          'unit': 'Nos',
          'bin': 'C-02-02',
          'picked': false,
        },
        {
          'lineNo': '5',
          'itemCode': 'DOC-WC',
          'description': 'Warranty Card & Manuals',
          'qty': 3.0,
          'unit': 'Sets',
          'bin': 'C-03-01',
          'picked': false,
        },
      ],
    },
    {
      'id': 'pl2',
      'plNumber': 'PL-2024-018',
      'doNumber': 'DO-2024-088',
      'customer': 'Hydro Systems Ltd.',
      'dispatchDate': DateTime.now().add(const Duration(hours: 5)),
      'status': 'In Progress',
      'pickedLines': 2,
      'lines': [
        {
          'lineNo': '1',
          'itemCode': 'FG-HPA-2000',
          'description': 'Hydraulic Pump Assembly HPA-2000',
          'qty': 2.0,
          'unit': 'Nos',
          'bin': 'C-01-01',
          'picked': true,
        },
        {
          'lineNo': '2',
          'itemCode': 'SP-SEAL-KIT',
          'description': 'Spare Seal Kit',
          'qty': 4.0,
          'unit': 'Kits',
          'bin': 'C-02-01',
          'picked': true,
        },
        {
          'lineNo': '3',
          'itemCode': 'DOC-WC',
          'description': 'Warranty Card & Manuals',
          'qty': 2.0,
          'unit': 'Sets',
          'bin': 'C-03-01',
          'picked': false,
        },
      ],
    },
  ];

  // ── Cycle Counts ─────────────────────────────────────────────────────────────

  static final List<Map<String, dynamic>> cycleCounts = [
    {
      'id': 'cc1',
      'ccNumber': 'CC-2024-015',
      'zone': 'Zone A – Raw Materials',
      'dueDate': DateTime.now().add(const Duration(hours: 6)),
      'status': 'Pending',
      'lines': [
        {
          'binCode': 'A-01-03',
          'itemCode': 'RM-SS316-25',
          'description': 'SS316 Round Bar 25mm',
          'systemQty': 488.0,
          'unit': 'Nos',
          'actualQty': null,
        },
        {
          'binCode': 'A-01-04',
          'itemCode': 'RM-SS316-50',
          'description': 'SS316 Round Bar 50mm',
          'systemQty': 190.0,
          'unit': 'Nos',
          'actualQty': null,
        },
        {
          'binCode': 'A-02-01',
          'itemCode': 'RM-BRG-6205',
          'description': 'Bearing 6205ZZ',
          'systemQty': 142.0,
          'unit': 'Nos',
          'actualQty': null,
        },
        {
          'binCode': 'A-03-02',
          'itemCode': 'RM-SEAL-B',
          'description': 'Hydraulic Seal Kit B',
          'systemQty': 74.0,
          'unit': 'Kits',
          'actualQty': null,
        },
        {
          'binCode': 'A-04-01',
          'itemCode': 'RM-BOLT-M12',
          'description': 'M12 Hex Bolt',
          'systemQty': 952.0,
          'unit': 'Nos',
          'actualQty': null,
        },
      ],
    },
    {
      'id': 'cc2',
      'ccNumber': 'CC-2024-014',
      'zone': 'Zone C – Finished Goods',
      'dueDate': DateTime.now().subtract(const Duration(hours: 12)),
      'status': 'Overdue',
      'lines': [
        {
          'binCode': 'C-01-01',
          'itemCode': 'FG-HPA-2000',
          'description': 'Hydraulic Pump Assembly HPA-2000',
          'systemQty': 8.0,
          'unit': 'Nos',
          'actualQty': null,
        },
        {
          'binCode': 'C-01-02',
          'itemCode': 'FG-CVA-500',
          'description': 'Control Valve Assembly CVA-500',
          'systemQty': 5.0,
          'unit': 'Nos',
          'actualQty': null,
        },
      ],
    },
    {
      'id': 'cc3',
      'ccNumber': 'CC-2024-013',
      'zone': 'Zone B – WIP',
      'dueDate': DateTime.now().add(const Duration(days: 1)),
      'status': 'Pending',
      'lines': [
        {
          'binCode': 'B-01-01',
          'itemCode': 'WIP-PUMP-BODY',
          'description': 'Pump Body – Machined',
          'systemQty': 12.0,
          'unit': 'Nos',
          'actualQty': null,
        },
        {
          'binCode': 'B-02-01',
          'itemCode': 'WIP-PUMP-SHAFT',
          'description': 'Pump Shaft – Ground',
          'systemQty': 12.0,
          'unit': 'Nos',
          'actualQty': null,
        },
        {
          'binCode': 'B-03-01',
          'itemCode': 'WIP-COVER',
          'description': 'Pump Cover Assembly',
          'systemQty': 10.0,
          'unit': 'Nos',
          'actualQty': null,
        },
      ],
    },
  ];

  // ── Stock Items ──────────────────────────────────────────────────────────────

  static const List<StockItem> stockItems = [
    StockItem(
      itemCode: 'RM-SS316-25',
      description: 'SS316 Round Bar 25mm',
      category: 'Raw Material',
      unit: 'Nos',
      binStocks: [
        BinStock(
          binCode: 'A-01-03',
          zone: 'Zone A',
          qty: 488,
          unit: 'Nos',
          batchNumber: 'BT-2024-087',
        ),
        BinStock(
          binCode: 'A-01-05',
          zone: 'Zone A',
          qty: 150,
          unit: 'Nos',
          batchNumber: 'BT-2024-090',
        ),
      ],
    ),
    StockItem(
      itemCode: 'RM-SS316-50',
      description: 'SS316 Round Bar 50mm',
      category: 'Raw Material',
      unit: 'Nos',
      binStocks: [
        BinStock(
          binCode: 'A-01-04',
          zone: 'Zone A',
          qty: 190,
          unit: 'Nos',
          batchNumber: 'BT-2024-091',
        ),
      ],
    ),
    StockItem(
      itemCode: 'RM-BRG-6205',
      description: 'Bearing 6205ZZ Deep Groove',
      category: 'Raw Material',
      unit: 'Nos',
      binStocks: [
        BinStock(
          binCode: 'A-02-01',
          zone: 'Zone A',
          qty: 142,
          unit: 'Nos',
          batchNumber: 'BT-2024-089',
        ),
      ],
    ),
    StockItem(
      itemCode: 'RM-SEAL-B',
      description: 'Hydraulic Seal Kit – Type B',
      category: 'Raw Material',
      unit: 'Kits',
      binStocks: [
        BinStock(
          binCode: 'A-03-02',
          zone: 'Zone A',
          qty: 74,
          unit: 'Kits',
          batchNumber: 'BT-2024-092',
        ),
        BinStock(
          binCode: 'A-03-03',
          zone: 'Zone A',
          qty: 26,
          unit: 'Kits',
          batchNumber: 'BT-2024-088',
        ),
      ],
    ),
    StockItem(
      itemCode: 'FG-HPA-2000',
      description: 'Hydraulic Pump Assembly HPA-2000',
      category: 'Finished Goods',
      unit: 'Nos',
      binStocks: [
        BinStock(
          binCode: 'C-01-01',
          zone: 'Zone C',
          qty: 8,
          unit: 'Nos',
          batchNumber: 'BT-2024-087',
        ),
      ],
    ),
    StockItem(
      itemCode: 'FG-CVA-500',
      description: 'Control Valve Assembly CVA-500',
      category: 'Finished Goods',
      unit: 'Nos',
      binStocks: [
        BinStock(
          binCode: 'C-01-02',
          zone: 'Zone C',
          qty: 5,
          unit: 'Nos',
          batchNumber: 'BT-2024-083',
        ),
      ],
    ),
    StockItem(
      itemCode: 'RM-BOLT-M12',
      description: 'M12 Hex Bolt Grade 8.8',
      category: 'Raw Material',
      unit: 'Nos',
      binStocks: [
        BinStock(
          binCode: 'A-04-01',
          zone: 'Zone A',
          qty: 952,
          unit: 'Nos',
          batchNumber: 'BT-2024-085',
        ),
      ],
    ),
    StockItem(
      itemCode: 'WIP-PUMP-BODY',
      description: 'Pump Body – Machined',
      category: 'WIP',
      unit: 'Nos',
      binStocks: [
        BinStock(binCode: 'B-01-01', zone: 'Zone B', qty: 12, unit: 'Nos'),
      ],
    ),
  ];

  // ── Warehouse Bins ───────────────────────────────────────────────────────────

  static const List<WarehouseBin> bins = [
    WarehouseBin(
      binCode: 'A-01-03',
      zone: 'Zone A',
      aisle: 'A-01',
      rack: '03',
      level: 'Ground',
      category: 'Raw Material',
      contents: [
        BinContent(
          itemCode: 'RM-SS316-25',
          description: 'SS316 Round Bar 25mm',
          qty: 488,
          unit: 'Nos',
          batchNumber: 'BT-2024-087',
        ),
      ],
    ),
    WarehouseBin(
      binCode: 'A-02-01',
      zone: 'Zone A',
      aisle: 'A-02',
      rack: '01',
      level: 'Ground',
      category: 'Raw Material',
      contents: [
        BinContent(
          itemCode: 'RM-BRG-6205',
          description: 'Bearing 6205ZZ',
          qty: 142,
          unit: 'Nos',
          batchNumber: 'BT-2024-089',
        ),
      ],
    ),
    WarehouseBin(
      binCode: 'A-03-02',
      zone: 'Zone A',
      aisle: 'A-03',
      rack: '02',
      level: 'Shelf 1',
      category: 'Raw Material',
      contents: [
        BinContent(
          itemCode: 'RM-SEAL-B',
          description: 'Hydraulic Seal Kit B',
          qty: 74,
          unit: 'Kits',
          batchNumber: 'BT-2024-092',
        ),
        BinContent(
          itemCode: 'RM-GASKET-G1',
          description: 'Gasket G1',
          qty: 480,
          unit: 'Nos',
          batchNumber: 'BT-2024-083',
        ),
      ],
    ),
    WarehouseBin(
      binCode: 'B-01-01',
      zone: 'Zone B',
      aisle: 'B-01',
      rack: '01',
      level: 'Ground',
      category: 'WIP',
      contents: [
        BinContent(
          itemCode: 'WIP-PUMP-BODY',
          description: 'Pump Body – Machined',
          qty: 12,
          unit: 'Nos',
        ),
        BinContent(
          itemCode: 'WIP-PUMP-SHAFT',
          description: 'Pump Shaft – Ground',
          qty: 12,
          unit: 'Nos',
        ),
      ],
    ),
    WarehouseBin(
      binCode: 'C-01-01',
      zone: 'Zone C',
      aisle: 'C-01',
      rack: '01',
      level: 'Ground',
      category: 'Finished Goods',
      contents: [
        BinContent(
          itemCode: 'FG-HPA-2000',
          description: 'Hydraulic Pump Assembly HPA-2000',
          qty: 8,
          unit: 'Nos',
          batchNumber: 'BT-2024-087',
        ),
      ],
    ),
    WarehouseBin(
      binCode: 'A-04-02',
      zone: 'Zone A',
      aisle: 'A-04',
      rack: '02',
      level: 'Shelf 2',
      category: 'Raw Material',
      contents: [],
    ),
  ];

  // ── Zones for browser ────────────────────────────────────────────────────────

  static const List<Map<String, dynamic>> zones = [
    {
      'code': 'A',
      'name': 'Zone A – Raw Materials',
      'binCount': 24,
      'occupiedBins': 18,
      'icon': 'raw',
    },
    {
      'code': 'B',
      'name': 'Zone B – WIP',
      'binCount': 12,
      'occupiedBins': 7,
      'icon': 'wip',
    },
    {
      'code': 'C',
      'name': 'Zone C – Finished Goods',
      'binCount': 16,
      'occupiedBins': 5,
      'icon': 'fg',
    },
  ];

  // ── Stock Ledger (reuse same format) ─────────────────────────────────────────

  static const List<StockLedgerEntry> stockLedger = [
    StockLedgerEntry(
      date: '08 Jul 2024',
      movementType: 'GRN',
      quantity: 500,
      unit: 'Nos',
      balance: 500,
      reference: 'PO-2024-031',
    ),
    StockLedgerEntry(
      date: '10 Jul 2024',
      movementType: 'Issue',
      quantity: -12,
      unit: 'Nos',
      balance: 488,
      reference: 'MR-2024-098',
    ),
    StockLedgerEntry(
      date: '11 Jul 2024',
      movementType: 'Transfer',
      quantity: -50,
      unit: 'Nos',
      balance: 438,
      reference: 'TRF-2024-021',
    ),
    StockLedgerEntry(
      date: '12 Jul 2024',
      movementType: 'GRN',
      quantity: 200,
      unit: 'Nos',
      balance: 638,
      reference: 'PO-2024-035',
    ),
    StockLedgerEntry(
      date: '15 Jul 2024',
      movementType: 'Issue',
      quantity: -150,
      unit: 'Nos',
      balance: 488,
      reference: 'MR-2024-112',
    ),
  ];
}
