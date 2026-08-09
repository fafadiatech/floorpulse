import '../models/work_order.dart';
import '../models/job.dart';

class MockData {
  static final List<WorkOrder> workOrders = [
    WorkOrder(
      id: '1',
      woNumber: 'WO-2024-001',
      productName: 'Hydraulic Pump Assembly',
      quantity: 50,
      completedQty: 32,
      dueDate: DateTime.now().add(const Duration(days: 3)),
      status: WorkOrderStatus.inProgress,
      priority: Priority.high,
      assignedTeam: 'Assembly Line A',
      description:
          'Manufacture and assemble hydraulic pump units for client order #4521. All components must pass pressure testing before final assembly.',
    ),
    WorkOrder(
      id: '2',
      woNumber: 'WO-2024-002',
      productName: 'Steel Frame Bracket',
      quantity: 200,
      completedQty: 200,
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      status: WorkOrderStatus.completed,
      priority: Priority.medium,
      assignedTeam: 'Fabrication Unit B',
      description:
          'Fabricate steel frame brackets as per engineering spec ES-2024-78. Material grade: A36 steel.',
    ),
    WorkOrder(
      id: '3',
      woNumber: 'WO-2024-003',
      productName: 'Control Panel Unit',
      quantity: 10,
      completedQty: 0,
      dueDate: DateTime.now().add(const Duration(days: 7)),
      status: WorkOrderStatus.pending,
      priority: Priority.critical,
      assignedTeam: 'Electronics Team',
      description:
          'Assemble and wire control panel units for factory automation project. Includes PLC integration and HMI setup.',
    ),
    WorkOrder(
      id: '4',
      woNumber: 'WO-2024-004',
      productName: 'Conveyor Belt Module',
      quantity: 15,
      completedQty: 8,
      dueDate: DateTime.now().add(const Duration(days: 5)),
      status: WorkOrderStatus.inProgress,
      priority: Priority.medium,
      assignedTeam: 'Assembly Line B',
      description:
          'Manufacture conveyor belt modules for warehouse expansion. Includes roller alignment and belt tensioning.',
    ),
    WorkOrder(
      id: '5',
      woNumber: 'WO-2024-005',
      productName: 'Pneumatic Valve Set',
      quantity: 100,
      completedQty: 45,
      dueDate: DateTime.now().add(const Duration(days: 2)),
      status: WorkOrderStatus.onHold,
      priority: Priority.high,
      assignedTeam: 'Quality Control',
      description:
          'Production on hold pending material inspection clearance from QC. Resume after batch certification.',
    ),
  ];

  static final List<Job> myJobs = [
    Job(
      id: 'j1',
      jobNumber: 'JOB-001',
      title: 'Inspect Hydraulic Components',
      workOrderId: '1',
      workOrderNumber: 'WO-2024-001',
      status: JobStatus.inProgress,
      dueDate: DateTime.now().add(const Duration(days: 1)),
      description:
          'Perform quality inspection on incoming hydraulic components before assembly. Check dimensions, surface finish, and material certificates.',
      location: 'Bay 3 - Receiving Dock',
      notes: ['Batch A cleared', 'Batch B pending re-inspection'],
    ),
    Job(
      id: 'j2',
      jobNumber: 'JOB-002',
      title: 'Weld Frame Sections',
      workOrderId: '2',
      workOrderNumber: 'WO-2024-002',
      status: JobStatus.completed,
      dueDate: DateTime.now().subtract(const Duration(days: 2)),
      description:
          'Weld all steel frame sections as per blueprint FRM-2024-12. Use MIG welding process, wire feed rate 4.5 m/min.',
      location: 'Welding Station 2',
      notes: [
        'Completed ahead of schedule',
        'All welds passed visual inspection',
      ],
    ),
    Job(
      id: 'j3',
      jobNumber: 'JOB-003',
      title: 'Wire Control Panels',
      workOrderId: '3',
      workOrderNumber: 'WO-2024-003',
      status: JobStatus.notStarted,
      dueDate: DateTime.now().add(const Duration(days: 6)),
      description:
          'Install and wire all electrical components on control panel chassis. Follow wiring diagram EL-2024-55.',
      location: 'Electronics Lab',
      notes: [],
    ),
    Job(
      id: 'j4',
      jobNumber: 'JOB-004',
      title: 'Install Conveyor Rollers',
      workOrderId: '4',
      workOrderNumber: 'WO-2024-004',
      status: JobStatus.inProgress,
      dueDate: DateTime.now().add(const Duration(days: 4)),
      description:
          'Mount and align conveyor rollers on the module frame. Ensure proper spacing and alignment before tensioning belt.',
      location: 'Assembly Line B - Station 5',
      notes: [
        'Alignment tool checked out from tool room',
        'Torque spec: 45 Nm',
      ],
    ),
  ];

  static const Map<String, dynamic> dashboardStats = {
    'activeWorkOrders': 3,
    'completedToday': 12,
    'productionEfficiency': 87.5,
    'openAlerts': 2,
    'pendingInspections': 5,
    'onTimeDelivery': 94.2,
  };

  static const Map<String, String> currentUser = {
    'name': 'Alex Johnson',
    'role': 'Senior Technician',
    'employeeId': 'EMP-0042',
    'department': 'Assembly',
    'initials': 'AJ',
  };
}
