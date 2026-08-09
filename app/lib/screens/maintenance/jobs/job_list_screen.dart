import 'package:flutter/material.dart';
import '../../../data/maintenance_mock_data.dart';
import '../../../models/maintenance_asset.dart';
import '../../../models/maintenance_job.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/date_utils.dart';
import 'job_execution_screen.dart';

class JobListScreen extends StatefulWidget {
  final String? filterStatus;

  const JobListScreen({super.key, this.filterStatus});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    if (widget.filterStatus == 'down') {
      _selectedFilter = 'Breakdown';
    }
  }

  List<MaintenanceJob> get _filteredJobs {
    final jobs = MaintenanceMockData.jobs;
    switch (_selectedFilter) {
      case 'Open':
        return jobs
            .where((j) => j.status == MaintenanceJobStatus.open)
            .toList();
      case 'In Progress':
        return jobs
            .where((j) => j.status == MaintenanceJobStatus.inProgress)
            .toList();
      case 'Pending Parts':
        return jobs
            .where((j) => j.status == MaintenanceJobStatus.pendingParts)
            .toList();
      case 'Breakdown':
        return jobs
            .where((j) => j.type == MaintenanceJobType.breakdown)
            .toList();
      case 'PM':
        return jobs.where((j) => j.type == MaintenanceJobType.pm).toList();
      case 'Closed':
        return jobs
            .where((j) => j.status == MaintenanceJobStatus.closed)
            .toList();
      default:
        return jobs;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = [
      'All',
      'Open',
      'In Progress',
      'Pending Parts',
      'Breakdown',
      'PM',
      'Closed',
    ];
    final jobs = _filteredJobs;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Work Orders',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filters.map((f) {
                  final isActive = f == _selectedFilter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f),
                      selected: isActive,
                      selectedColor: AppTheme.primary.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: isActive
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                      onSelected: (_) => setState(() => _selectedFilter = f),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1, color: AppTheme.divider),

          // Job list
          Expanded(
            child: jobs.isEmpty
                ? const Center(
                    child: Text(
                      'No work orders found',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: jobs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      return _JobCard(
                        job: job,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JobExecutionScreen(job: job),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final MaintenanceJob job;
  final VoidCallback onTap;

  const _JobCard({required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusLabel;
    switch (job.status) {
      case MaintenanceJobStatus.inProgress:
        statusColor = AppTheme.primary;
        statusLabel = 'In Progress';
        break;
      case MaintenanceJobStatus.pendingParts:
        statusColor = AppTheme.warning;
        statusLabel = 'Pending Parts';
        break;
      case MaintenanceJobStatus.closed:
        statusColor = AppTheme.success;
        statusLabel = 'Closed';
        break;
      default:
        statusColor = AppTheme.textSecondary;
        statusLabel = 'Open';
    }

    // Find asset status
    final assets = MaintenanceMockData.assets;
    final asset = assets.firstWhere(
      (a) => a.id == job.assetId,
      orElse: () => MaintenanceAsset(
        id: '',
        name: '',
        tag: '',
        location: '',
        category: '',
        status: AssetStatus.idle,
        lastPM: DateTime.now(),
        nextPM: DateTime.now(),
        meters: {},
        technician: '',
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: job.priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    job.type == MaintenanceJobType.breakdown
                        ? Icons.flash_on
                        : job.type == MaintenanceJobType.pm
                        ? Icons.event_repeat
                        : Icons.speed,
                    color: job.priorityColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.workOrderNo,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        job.assetName,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: statusColor, width: 1),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: job.priorityColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        job.priority,
                        style: TextStyle(
                          color: job.priorityColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppTheme.divider),
            const SizedBox(height: 10),
            Row(
              children: [
                _InfoChip(icon: Icons.category_outlined, label: job.typeLabel),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.location_on_outlined,
                  label: job.location,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.access_time_outlined,
                  label: AppDateUtils.timeAgo(job.reportedAt),
                ),
              ],
            ),
            if (job.status == MaintenanceJobStatus.inProgress &&
                job.elapsed != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    color: AppTheme.primary,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Running: ${_formatDuration(job.elapsed!)}',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            if (asset.status == AssetStatus.down &&
                job.status != MaintenanceJobStatus.closed) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.circle, color: AppTheme.danger, size: 8),
                    const SizedBox(width: 6),
                    const Text(
                      'Machine Down',
                      style: TextStyle(
                        color: AppTheme.danger,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    return '${h}h ${m}m';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppTheme.textSecondary),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
        ),
      ],
    );
  }
}
