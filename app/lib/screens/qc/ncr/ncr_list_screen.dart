import 'package:flutter/material.dart';
import '../../../data/qc_mock_data.dart';
import '../../../models/ncr.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/date_utils.dart';
import 'ncr_detail_screen.dart';

class NCRListScreen extends StatelessWidget {
  const NCRListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ncrs = QCMockData.ncrs;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('NCR Register'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.danger.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.danger.withValues(alpha: 0.3)),
            ),
            child: Text(
              '${ncrs.length} total',
              style: const TextStyle(
                color: AppTheme.danger,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ncrs.length,
        itemBuilder: (context, index) => _NCRCard(
          ncr: ncrs[index],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NCRDetailScreen(ncr: ncrs[index]),
            ),
          ),
        ),
      ),
    );
  }
}

class _NCRCard extends StatelessWidget {
  final NCR ncr;
  final VoidCallback onTap;

  const _NCRCard({required this.ncr, required this.onTap});

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
    final severityColor = _severityColor(ncr.severity);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: Column(
          children: [
            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    ncr.ncrNumber,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  _Badge(label: _statusLabel(ncr.status), color: statusColor),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ncr.productName,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ncr.defectType,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _Badge(
                        label: _severityLabel(ncr.severity),
                        color: severityColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Qty: ${ncr.quantityRejected}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppDateUtils.format(ncr.raisedDate),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
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
