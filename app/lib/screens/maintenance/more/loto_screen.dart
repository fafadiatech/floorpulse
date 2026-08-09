import 'package:flutter/material.dart';
import '../../../data/maintenance_mock_data.dart';
import '../../../models/maintenance_job.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/date_utils.dart';

class LotoScreen extends StatelessWidget {
  const LotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lotoJobs = MaintenanceMockData.jobs
        .where((j) => j.lotoStatus != LotoStatus.notRequired)
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'LOTO Management',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.warning.withValues(alpha: 0.4),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_outlined, color: AppTheme.warning, size: 32),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lockout / Tagout Register',
                          style: TextStyle(
                            color: AppTheme.warning,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Track energy isolation status for all active maintenance work.',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'LOTO Register',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            ...lotoJobs.map((job) => _LotoCard(job: job)),

            if (lotoJobs.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    'No active LOTO entries',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _LotoCard extends StatelessWidget {
  final MaintenanceJob job;

  const _LotoCard({required this.job});

  Color get _lotoColor {
    switch (job.lotoStatus) {
      case LotoStatus.pending:
        return AppTheme.warning;
      case LotoStatus.applied:
        return AppTheme.danger;
      case LotoStatus.removed:
        return AppTheme.success;
      default:
        return AppTheme.textSecondary;
    }
  }

  String get _lotoLabel {
    switch (job.lotoStatus) {
      case LotoStatus.pending:
        return 'Pending';
      case LotoStatus.applied:
        return 'Applied';
      case LotoStatus.removed:
        return 'Removed';
      default:
        return 'Not Required';
    }
  }

  IconData get _lotoIcon {
    switch (job.lotoStatus) {
      case LotoStatus.applied:
        return Icons.lock;
      case LotoStatus.removed:
        return Icons.lock_open;
      default:
        return Icons.lock_clock_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _lotoColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_lotoIcon, color: _lotoColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.assetName,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${job.workOrderNo} · ${job.assignedTo}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Reported: ${AppDateUtils.timeAgo(job.reportedAt)}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _lotoColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _lotoColor, width: 1),
            ),
            child: Text(
              _lotoLabel,
              style: TextStyle(
                color: _lotoColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
