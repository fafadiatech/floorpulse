import 'package:flutter/material.dart';

import '../models/inspection_item.dart';
import '../models/job.dart';
import '../models/maintenance_asset.dart';
import '../models/maintenance_job.dart';
import '../models/ncr.dart';
import '../models/scan_hit.dart';
import '../models/warehouse_bin.dart';
import '../models/work_order.dart';
import '../screens/maintenance/assets/asset_detail_screen.dart';
import '../screens/maintenance/jobs/job_execution_screen.dart';
import '../screens/my_jobs/job_detail_screen.dart';
import '../screens/qc/ncr/ncr_detail_screen.dart';
import '../screens/qc/queue/inspection_detail_screen.dart';
import '../screens/qc/scan/traceability_tree_screen.dart';
import '../screens/warehouse/grn/grn_list_screen.dart';
import '../screens/warehouse/more/gate_entry_screen.dart';
import '../screens/warehouse/stock/bin_contents_screen.dart';
import '../screens/warehouse/tasks/tasks_screen.dart';
import '../screens/work_orders/work_order_detail_screen.dart';
import '../theme/app_theme.dart';
import 'floorpulse_api.dart';
import 'frappe_exception.dart';

Future<void> resolveAndOpenScan(BuildContext context, String code) async {
  final trimmed = code.trim();
  if (trimmed.isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Enter a code to scan')));
    return;
  }
  try {
    final hit = await FloorPulseApi.instance.resolveScan(trimmed);
    if (!context.mounted) return;
    openScanHit(context, hit);
  } on FrappeException catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(e.message)));
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
  }
}

void openScanHit(BuildContext context, ScanHit hit) {
  final page = _pageFor(hit);
  if (page == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No screen for ${hit.doctype} ${hit.name}')),
    );
    return;
  }
  Navigator.push(context, MaterialPageRoute(builder: (_) => page));
}

Widget? _pageFor(ScanHit hit) {
  switch (hit.doctype) {
    case 'Job Card':
      return JobDetailScreen(job: _jobStub(hit));
    case 'Work Order':
      return WorkOrderDetailScreen(workOrder: _workOrderStub(hit));
    case 'Asset':
      return AssetDetailScreen(asset: _assetStub(hit));
    case 'Asset Repair':
      return JobExecutionScreen(job: _repairStub(hit));
    case 'Quality Inspection':
      return InspectionDetailScreen(item: _inspectionStub(hit));
    case 'NCR':
      return NCRDetailScreen(ncr: _ncrStub(hit));
    case 'Purchase Order':
      return const GRNListScreen();
    case 'Gate Entry':
      return const GateEntryScreen();
    case 'Bin':
      return BinContentsScreen(bin: _binStub(hit));
    case 'Warehouse Task':
      return const TasksScreen();
    case 'Item':
    case 'Batch':
    case 'Serial No':
      return const TraceabilityTreeScreen();
    default:
      return null;
  }
}

Job _jobStub(ScanHit hit) => Job(
  id: hit.name,
  jobNumber: hit.name,
  title: hit.label,
  workOrderId: '${hit.extra['work_order'] ?? ''}',
  workOrderNumber: '${hit.extra['work_order'] ?? ''}',
  status: JobStatus.notStarted,
  dueDate: DateTime.now(),
  description: hit.label,
  location: '',
);

WorkOrder _workOrderStub(ScanHit hit) => WorkOrder(
  id: hit.name,
  woNumber: hit.name,
  productName: hit.label,
  quantity: 0,
  completedQty: 0,
  dueDate: DateTime.now(),
  status: WorkOrderStatus.pending,
  priority: Priority.medium,
  assignedTeam: '',
  description: hit.label,
);

MaintenanceAsset _assetStub(ScanHit hit) => MaintenanceAsset(
  id: hit.name,
  name: hit.label,
  tag: hit.name,
  location: '',
  category: '',
  status: AssetStatus.idle,
  lastPM: DateTime.now(),
  nextPM: DateTime.now(),
  meters: const {},
  technician: '',
);

MaintenanceJob _repairStub(ScanHit hit) => MaintenanceJob(
  id: hit.name,
  workOrderNo: hit.name,
  assetId: '',
  assetName: hit.label,
  assetTag: '',
  location: '',
  type: MaintenanceJobType.breakdown,
  status: MaintenanceJobStatus.open,
  priority: 'Medium',
  reportedBy: '',
  assignedTo: '',
  reportedAt: DateTime.now(),
  lotoStatus: LotoStatus.notRequired,
  checklist: [],
  consumedSpares: [],
);

InspectionItem _inspectionStub(ScanHit hit) => InspectionItem(
  id: hit.name,
  referenceNumber: hit.name,
  productName: hit.label,
  type: InspectionType.inProcess,
  status: InspectionStatus.pending,
  dueDate: DateTime.now(),
  assignedTo: '',
  quantity: 0,
);

NCR _ncrStub(ScanHit hit) => NCR(
  ncrNumber: hit.name,
  productName: hit.label,
  referenceNumber: hit.name,
  defectType: hit.label,
  quantityRejected: 0,
  severity: NCRSeverity.minor,
  status: NCRStatus.open,
  raisedDate: DateTime.now(),
  raisedBy: '',
);

WarehouseBin _binStub(ScanHit hit) => WarehouseBin(
  binCode: hit.name,
  zone: hit.label,
  aisle: '',
  rack: '',
  level: '',
  category: '',
);

class ScanCodeField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final bool dark;

  const ScanCodeField({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.dark = true,
  });

  @override
  Widget build(BuildContext context) {
    final fill = dark ? Colors.white.withValues(alpha: 0.08) : Colors.white;
    final textColor = dark ? Colors.white : AppTheme.textPrimary;
    final hintColor = dark ? Colors.white54 : AppTheme.textSecondary;

    return TextField(
      controller: controller,
      style: TextStyle(color: textColor),
      textInputAction: TextInputAction.go,
      onSubmitted: (_) => onSubmit(),
      decoration: InputDecoration(
        hintText: 'Enter barcode / document name',
        hintStyle: TextStyle(color: hintColor, fontSize: 13),
        filled: true,
        fillColor: fill,
        prefixIcon: Icon(Icons.qr_code_2, color: hintColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: dark ? Colors.white24 : AppTheme.divider,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: dark ? Colors.white24 : AppTheme.divider,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }
}
