import 'package:flutter/material.dart';
import '../../../models/ncr.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/date_utils.dart';
import 'capa_screen.dart';

class NCRDetailScreen extends StatelessWidget {
  final NCR ncr;

  const NCRDetailScreen({super.key, required this.ncr});

  Color _statusColor(NCRStatus s) {
    switch (s) {
      case NCRStatus.open:
        return AppTheme.danger;
      case NCRStatus.underReview:
        return AppTheme.warning;
      case NCRStatus.capaRaised:
        return AppTheme.primary;
      case NCRStatus.closed:
        return AppTheme.success;
    }
  }

  String _statusLabel(NCRStatus s) {
    switch (s) {
      case NCRStatus.open:
        return 'Open';
      case NCRStatus.underReview:
        return 'Under Review';
      case NCRStatus.capaRaised:
        return 'CAPA Raised';
      case NCRStatus.closed:
        return 'Closed';
    }
  }

  Color _severityColor(NCRSeverity s) {
    switch (s) {
      case NCRSeverity.critical:
        return AppTheme.danger;
      case NCRSeverity.major:
        return AppTheme.warning;
      case NCRSeverity.minor:
        return AppTheme.success;
    }
  }

  String _severityLabel(NCRSeverity s) {
    switch (s) {
      case NCRSeverity.critical:
        return 'Critical';
      case NCRSeverity.major:
        return 'Major';
      case NCRSeverity.minor:
        return 'Minor';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(ncr.status);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text(ncr.ncrNumber)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 10, color: statusColor),
                  const SizedBox(width: 8),
                  Text(
                    _statusLabel(ncr.status),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Details card
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _badge(
                        _severityLabel(ncr.severity),
                        _severityColor(ncr.severity),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ncr.productName,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(label: 'Reference', value: ncr.referenceNumber),
                  _DetailRow(label: 'Defect Type', value: ncr.defectType),
                  _DetailRow(
                    label: 'Qty Rejected',
                    value: '${ncr.quantityRejected} units',
                  ),
                  _DetailRow(label: 'Raised By', value: ncr.raisedBy),
                  _DetailRow(
                    label: 'Raised Date',
                    value: AppDateUtils.format(ncr.raisedDate),
                  ),
                  if (ncr.disposition != null)
                    _DetailRow(label: 'Disposition', value: ncr.disposition!),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // CAPA section
            const Text(
              'CAPA',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            if (ncr.capa != null) ...[
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          ncr.capa!.capaNumber,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        _capaStatusBadge(ncr.capa!.status),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _DetailRow(label: 'Owner', value: ncr.capa!.owner),
                    _DetailRow(
                      label: 'Due Date',
                      value: AppDateUtils.format(ncr.capa!.dueDate),
                      valueColor: ncr.capa!.status.name == 'overdue'
                          ? AppTheme.danger
                          : null,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CAPAScreen(capa: ncr.capa, createMode: false),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: const BorderSide(color: AppTheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'View CAPA',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.pending_actions_outlined,
                      size: 36,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'No CAPA raised yet',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CAPAScreen(ncr: ncr, createMode: true),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Raise CAPA',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
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

  Widget _capaStatusBadge(dynamic capaStatus) {
    Color color;
    String label;
    switch (capaStatus.toString()) {
      case 'CAPAStatus.closed':
        color = AppTheme.success;
        label = 'Closed';
        break;
      case 'CAPAStatus.inProgress':
        color = AppTheme.primary;
        label = 'In Progress';
        break;
      case 'CAPAStatus.overdue':
        color = AppTheme.danger;
        label = 'Overdue';
        break;
      default:
        color = AppTheme.warning;
        label = 'Open';
    }
    return _badge(label, color);
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
