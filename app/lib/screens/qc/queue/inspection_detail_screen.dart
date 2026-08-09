import 'package:flutter/material.dart';
import '../../../data/qc_mock_data.dart';
import '../../../models/inspection_item.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/date_utils.dart';
import 'reading_entry_screen.dart';

class InspectionDetailScreen extends StatelessWidget {
  final InspectionItem item;

  const InspectionDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final parameters = QCMockData.parametersFor(item.type);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text(item.referenceNumber)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _typeBadge(item.type),
                      const SizedBox(width: 8),
                      _statusBadge(item.status),
                      if (item.isOverdue) ...[
                        const SizedBox(width: 8),
                        _badge('Overdue', AppTheme.danger),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.productName,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(label: 'Reference', value: item.referenceNumber),
                  _DetailRow(label: 'Assigned To', value: item.assignedTo),
                  _DetailRow(
                    label: 'Quantity',
                    value: '${item.quantity} units',
                  ),
                  _DetailRow(
                    label: 'Due',
                    value: AppDateUtils.format(item.dueDate),
                    valueColor: item.isOverdue ? AppTheme.danger : null,
                  ),
                  if (item.supplier != null)
                    _DetailRow(label: 'Supplier', value: item.supplier!),
                  if (item.workCenter != null)
                    _DetailRow(label: 'Work Centre', value: item.workCenter!),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Parameters preview
            const Text(
              'Inspection Parameters',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _Card(
              child: Column(
                children: parameters.asMap().entries.map((entry) {
                  final i = entry.key;
                  final p = entry.value;
                  final isMeasurement = p.type.name == 'measurement';
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: isMeasurement
                                    ? AppTheme.primary.withValues(alpha: 0.1)
                                    : AppTheme.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                isMeasurement
                                    ? Icons.straighten
                                    : Icons.check_box_outlined,
                                size: 16,
                                color: isMeasurement
                                    ? AppTheme.primary
                                    : AppTheme.success,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                p.name,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.background,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppTheme.divider),
                              ),
                              child: Text(
                                isMeasurement ? 'Measurement' : 'Checklist',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (i < parameters.length - 1)
                        const Divider(height: 1, color: AppTheme.divider),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Start button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReadingEntryScreen(item: item),
                  ),
                ),
                icon: const Icon(Icons.play_arrow_outlined),
                label: const Text(
                  'Start Inspection',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _typeBadge(InspectionType type) {
    String label;
    switch (type) {
      case InspectionType.incoming:
        label = 'Incoming';
        break;
      case InspectionType.inProcess:
        label = 'In-Process';
        break;
      case InspectionType.finalInspection:
        label = 'Final';
        break;
    }
    return _badge(label, AppTheme.primary);
  }

  Widget _statusBadge(InspectionStatus status) {
    String label;
    Color color;
    switch (status) {
      case InspectionStatus.pending:
        label = 'Pending';
        color = AppTheme.warning;
        break;
      case InspectionStatus.inProgress:
        label = 'In Progress';
        color = AppTheme.primary;
        break;
      case InspectionStatus.completed:
        label = 'Completed';
        color = AppTheme.success;
        break;
      case InspectionStatus.overdue:
        label = 'Overdue';
        color = AppTheme.danger;
        break;
    }
    return _badge(label, color);
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color, width: 1.2),
        borderRadius: BorderRadius.circular(6),
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

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
