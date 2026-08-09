import 'package:flutter/material.dart';
import '../models/work_order.dart';
import '../models/job.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({super.key, required this.label, required this.color});

  factory StatusBadge.fromWorkOrderStatus(WorkOrderStatus status) {
    switch (status) {
      case WorkOrderStatus.pending:
        return const StatusBadge(label: 'Pending', color: AppTheme.warning);
      case WorkOrderStatus.inProgress:
        return const StatusBadge(label: 'In Progress', color: AppTheme.primary);
      case WorkOrderStatus.completed:
        return const StatusBadge(label: 'Completed', color: AppTheme.success);
      case WorkOrderStatus.onHold:
        return const StatusBadge(
          label: 'On Hold',
          color: AppTheme.textSecondary,
        );
    }
  }

  factory StatusBadge.fromJobStatus(JobStatus status) {
    switch (status) {
      case JobStatus.notStarted:
        return const StatusBadge(
          label: 'Not Started',
          color: AppTheme.textSecondary,
        );
      case JobStatus.inProgress:
        return const StatusBadge(label: 'In Progress', color: AppTheme.primary);
      case JobStatus.completed:
        return const StatusBadge(label: 'Completed', color: AppTheme.success);
      case JobStatus.onHold:
        return const StatusBadge(label: 'On Hold', color: AppTheme.warning);
    }
  }

  factory StatusBadge.fromPriority(Priority priority) {
    switch (priority) {
      case Priority.low:
        return const StatusBadge(label: 'Low', color: AppTheme.success);
      case Priority.medium:
        return const StatusBadge(label: 'Medium', color: AppTheme.primary);
      case Priority.high:
        return const StatusBadge(label: 'High', color: AppTheme.warning);
      case Priority.critical:
        return const StatusBadge(label: 'Critical', color: AppTheme.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.2),
        borderRadius: BorderRadius.circular(6),
        color: color.withValues(alpha: 0.08),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
