import 'dart:async';
import 'package:flutter/material.dart';
import '../../../models/maintenance_job.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/date_utils.dart';
import 'checklist_screen.dart';
import 'consume_spares_screen.dart';
import 'closeout_screen.dart';

class JobExecutionScreen extends StatefulWidget {
  final MaintenanceJob job;

  const JobExecutionScreen({super.key, required this.job});

  @override
  State<JobExecutionScreen> createState() => _JobExecutionScreenState();
}

class _JobExecutionScreenState extends State<JobExecutionScreen> {
  late MaintenanceJob _job;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _job = widget.job;
    if (_job.status == MaintenanceJobStatus.inProgress &&
        _job.startedAt != null) {
      _elapsed = DateTime.now().difference(_job.startedAt!);
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _elapsed = _elapsed + const Duration(seconds: 1);
        });
      }
    });
  }

  void _confirmLoto() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: AppTheme.warning),
            SizedBox(width: 8),
            Text(
              'Confirm LOTO Applied',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: const Text(
          'I confirm that Lockout/Tagout has been properly applied to all energy sources on this equipment before proceeding with the work.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _job.lotoStatus = LotoStatus.applied;
                if (_job.status == MaintenanceJobStatus.open) {
                  _job.status = MaintenanceJobStatus.inProgress;
                  _job.startedAt = DateTime.now();
                  _elapsed = Duration.zero;
                  _startTimer();
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warning,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Confirm LOTO Applied',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _startJob() {
    setState(() {
      _job.status = MaintenanceJobStatus.inProgress;
      _job.startedAt = DateTime.now();
      _elapsed = Duration.zero;
      _startTimer();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Work order started — timer running')),
    );
  }

  String _formatElapsed(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Color get _statusColor {
    switch (_job.status) {
      case MaintenanceJobStatus.inProgress:
        return AppTheme.primary;
      case MaintenanceJobStatus.pendingParts:
        return AppTheme.warning;
      case MaintenanceJobStatus.closed:
        return AppTheme.success;
      default:
        return AppTheme.textSecondary;
    }
  }

  String get _statusLabel {
    switch (_job.status) {
      case MaintenanceJobStatus.inProgress:
        return 'In Progress';
      case MaintenanceJobStatus.pendingParts:
        return 'Pending Parts';
      case MaintenanceJobStatus.closed:
        return 'Closed';
      default:
        return 'Open';
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkedCount = _job.checklist.where((c) => c.isChecked).length;
    final checklistProgress = _job.checklist.isEmpty
        ? 0.0
        : checkedCount / _job.checklist.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _job.workOrderNo,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              _job.typeLabel,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _statusColor, width: 1),
            ),
            child: Text(
              _statusLabel,
              style: TextStyle(
                color: _statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Asset info card
            Container(
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
                          color: _job.priorityColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _job.type == MaintenanceJobType.breakdown
                              ? Icons.flash_on
                              : Icons.event_repeat,
                          color: _job.priorityColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _job.assetName,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${_job.assetTag} · ${_job.location}',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppTheme.divider),
                  const SizedBox(height: 10),
                  _InfoRow('Reported By', _job.reportedBy),
                  const SizedBox(height: 4),
                  _InfoRow('Reported At', AppDateUtils.format(_job.reportedAt)),
                  const SizedBox(height: 4),
                  _InfoRow(
                    'Priority',
                    _job.priority,
                    valueColor: _job.priorityColor,
                  ),
                  if (_job.startedAt != null) ...[
                    const SizedBox(height: 4),
                    _InfoRow(
                      'Started At',
                      AppDateUtils.format(_job.startedAt!),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // LOTO gate
            if (_job.lotoStatus == LotoStatus.pending) ...[
              _LotoGateCard(onConfirm: _confirmLoto),
              const SizedBox(height: 16),
            ],

            // Start button for open jobs without LOTO requirement
            if (_job.status == MaintenanceJobStatus.open &&
                _job.lotoStatus != LotoStatus.pending) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startJob,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text(
                    'Start Work Order',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Timer (when in progress)
            if (_job.status == MaintenanceJobStatus.inProgress) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary,
                      AppTheme.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Time Elapsed',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          _formatElapsed(_elapsed),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // LOTO status badge (applied)
            if (_job.lotoStatus == LotoStatus.applied) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.warning),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock, color: AppTheme.warning, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'LOTO Applied — Energy Isolated',
                      style: TextStyle(
                        color: AppTheme.warning,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Checklist progress
            if (_job.checklist.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Checklist Progress',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$checkedCount / ${_job.checklist.length}',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: checklistProgress,
                        backgroundColor: AppTheme.divider,
                        color: checklistProgress == 1.0
                            ? AppTheme.success
                            : AppTheme.primary,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action cards
            const Text(
              'Actions',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            _ActionCard(
              icon: Icons.checklist,
              title: 'Checklist Entry',
              subtitle:
                  '$checkedCount of ${_job.checklist.length} tasks completed',
              color: AppTheme.primary,
              enabled:
                  _job.status != MaintenanceJobStatus.open ||
                  _job.lotoStatus != LotoStatus.pending,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChecklistScreen(job: _job)),
                );
                setState(() {});
              },
            ),
            const SizedBox(height: 10),

            _ActionCard(
              icon: Icons.inventory_2_outlined,
              title: 'Consume Spares',
              subtitle: '${_job.consumedSpares.length} part(s) consumed',
              color: AppTheme.warning,
              enabled:
                  _job.status != MaintenanceJobStatus.open ||
                  _job.lotoStatus != LotoStatus.pending,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ConsumeSpareScreen(job: _job),
                  ),
                );
                setState(() {});
              },
            ),
            const SizedBox(height: 10),

            _ActionCard(
              icon: Icons.task_alt_outlined,
              title: 'Close-Out',
              subtitle: _job.status == MaintenanceJobStatus.closed
                  ? 'Completed · ${_job.faultCode ?? ''}'
                  : 'Fault code, photos & handover',
              color: AppTheme.success,
              enabled:
                  _job.status == MaintenanceJobStatus.inProgress ||
                  _job.status == MaintenanceJobStatus.pendingParts,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CloseoutScreen(job: _job)),
                );
                setState(() {});
              },
            ),

            if (_job.status == MaintenanceJobStatus.closed) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppTheme.success,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Work Order Closed',
                          style: TextStyle(
                            color: AppTheme.success,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    if (_job.closedAt != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Closed: ${AppDateUtils.format(_job.closedAt!)}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (_job.rootCause != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Root Cause: ${_job.rootCause}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (_job.hasHandoverSignature) ...[
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Icon(
                            Icons.draw_outlined,
                            size: 14,
                            color: AppTheme.success,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Handover signed',
                            style: TextStyle(
                              color: AppTheme.success,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _LotoGateCard extends StatelessWidget {
  final VoidCallback onConfirm;

  const _LotoGateCard({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warning, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lock_open_outlined, color: AppTheme.warning, size: 22),
              SizedBox(width: 8),
              Text(
                'Lockout / Tagout Required',
                style: TextStyle(
                  color: AppTheme.warning,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'This job requires energy isolation before work can begin. Apply LOTO to all energy sources and confirm below.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onConfirm,
              icon: const Icon(Icons.lock, size: 18),
              label: const Text(
                'Confirm LOTO Applied',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.warning,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = enabled ? color : AppTheme.textSecondary;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
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
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: effectiveColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: effectiveColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: effectiveColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppTheme.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
