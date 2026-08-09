import 'package:flutter/material.dart';
import '../../../data/maintenance_mock_data.dart';
import '../../../models/maintenance_job.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/date_utils.dart';

class DowntimeLogScreen extends StatelessWidget {
  const DowntimeLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Build downtime entries from closed breakdown jobs
    final closedBreakdowns = MaintenanceMockData.jobs
        .where(
          (j) =>
              j.type == MaintenanceJobType.breakdown &&
              j.status == MaintenanceJobStatus.closed &&
              j.startedAt != null &&
              j.closedAt != null,
        )
        .toList();

    // Also include open breakdowns
    final activeBreakdowns = MaintenanceMockData.jobs
        .where(
          (j) =>
              j.type == MaintenanceJobType.breakdown &&
              j.status != MaintenanceJobStatus.closed,
        )
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
          'Downtime Log',
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
            // MTTR card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary,
                    AppTheme.primary.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mean Time To Repair',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${MaintenanceMockData.dashboardStats['mttr']}h',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Text(
                          'Average this month',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.timer_outlined,
                    color: Colors.white54,
                    size: 48,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (activeBreakdowns.isNotEmpty) ...[
              const Text(
                'Currently Down',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              ...activeBreakdowns.map(
                (job) => _DowntimeCard(job: job, closed: false),
              ),
              const SizedBox(height: 16),
            ],

            if (closedBreakdowns.isNotEmpty) ...[
              const Text(
                'Resolved Breakdowns',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              ...closedBreakdowns.map(
                (job) => _DowntimeCard(job: job, closed: true),
              ),
            ],

            if (closedBreakdowns.isEmpty && activeBreakdowns.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    'No downtime records',
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

class _DowntimeCard extends StatelessWidget {
  final MaintenanceJob job;
  final bool closed;

  const _DowntimeCard({required this.job, required this.closed});

  String _durationLabel() {
    if (job.startedAt == null) return 'Not started';
    final end = job.closedAt ?? DateTime.now();
    final diff = end.difference(job.startedAt!);
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: closed ? AppTheme.success : AppTheme.danger,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job.assetName,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: (closed ? AppTheme.success : AppTheme.danger)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  closed ? 'Resolved' : 'Active',
                  style: TextStyle(
                    color: closed ? AppTheme.success : AppTheme.danger,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            job.workOrderNo,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _Stat(
                label: 'Reported',
                value: AppDateUtils.timeAgo(job.reportedAt),
              ),
              const SizedBox(width: 16),
              _Stat(label: 'Duration', value: _durationLabel()),
              const SizedBox(width: 16),
              _Stat(label: 'Priority', value: job.priority),
            ],
          ),
          if (job.faultCode != null) ...[
            const SizedBox(height: 6),
            Text(
              'Fault: ${job.faultCode}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
