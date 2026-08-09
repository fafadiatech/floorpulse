import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum MaintenanceJobType { breakdown, pm, meterBased }

enum MaintenanceJobStatus { open, inProgress, pendingParts, closed }

enum LotoStatus { notRequired, pending, applied, removed }

class ChecklistItem {
  final String id;
  final String task;
  bool isChecked;

  ChecklistItem({required this.id, required this.task, this.isChecked = false});
}

class ConsumedSpare {
  final String partNo;
  final String description;
  final double qty;
  final String unit;

  const ConsumedSpare({
    required this.partNo,
    required this.description,
    required this.qty,
    required this.unit,
  });
}

class MaintenanceJob {
  final String id;
  final String workOrderNo;
  final String assetId;
  final String assetName;
  final String assetTag;
  final String location;
  final MaintenanceJobType type;
  MaintenanceJobStatus status;
  final String priority;
  final String reportedBy;
  final String assignedTo;
  final DateTime reportedAt;
  DateTime? startedAt;
  DateTime? closedAt;
  LotoStatus lotoStatus;
  final List<ChecklistItem> checklist;
  final List<ConsumedSpare> consumedSpares;
  String? faultCode;
  String? rootCause;
  String? remarks;
  bool hasHandoverSignature;

  MaintenanceJob({
    required this.id,
    required this.workOrderNo,
    required this.assetId,
    required this.assetName,
    required this.assetTag,
    required this.location,
    required this.type,
    required this.status,
    required this.priority,
    required this.reportedBy,
    required this.assignedTo,
    required this.reportedAt,
    this.startedAt,
    this.closedAt,
    required this.lotoStatus,
    required this.checklist,
    required this.consumedSpares,
    this.faultCode,
    this.rootCause,
    this.remarks,
    this.hasHandoverSignature = false,
  });

  Duration? get elapsed =>
      startedAt != null ? DateTime.now().difference(startedAt!) : null;

  String get typeLabel {
    switch (type) {
      case MaintenanceJobType.breakdown:
        return 'Breakdown';
      case MaintenanceJobType.pm:
        return 'Preventive PM';
      case MaintenanceJobType.meterBased:
        return 'Meter-Based';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case 'Critical':
        return AppTheme.danger;
      case 'High':
        return AppTheme.warning;
      case 'Medium':
        return AppTheme.primary;
      default:
        return AppTheme.success;
    }
  }
}
