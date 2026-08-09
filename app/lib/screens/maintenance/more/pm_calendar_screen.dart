import 'package:flutter/material.dart';
import '../../../data/maintenance_mock_data.dart';
import '../../../models/maintenance_asset.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/date_utils.dart';

class PMCalendarScreen extends StatelessWidget {
  const PMCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final assets = MaintenanceMockData.assets;
    final now = DateTime.now();

    // Group assets into overdue, due this week, upcoming
    final overdue = assets.where((a) => a.nextPM.isBefore(now)).toList();
    final thisWeek = assets.where((a) {
      return !a.nextPM.isBefore(now) &&
          a.nextPM.isBefore(now.add(const Duration(days: 7)));
    }).toList();
    final upcoming = assets.where((a) {
      return a.nextPM.isAfter(now.add(const Duration(days: 7)));
    }).toList();

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
          'PM Calendar',
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
            // Summary row
            Row(
              children: [
                Expanded(
                  child: _SummaryChip(
                    label: 'Overdue',
                    count: overdue.length,
                    color: AppTheme.danger,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryChip(
                    label: 'This Week',
                    count: thisWeek.length,
                    color: AppTheme.warning,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryChip(
                    label: 'Upcoming',
                    count: upcoming.length,
                    color: AppTheme.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (overdue.isNotEmpty) ...[
              _sectionHeader('Overdue PM', AppTheme.danger),
              const SizedBox(height: 8),
              ...overdue.map((a) => _PMCard(asset: a, urgency: 'overdue')),
              const SizedBox(height: 16),
            ],

            if (thisWeek.isNotEmpty) ...[
              _sectionHeader('Due This Week', AppTheme.warning),
              const SizedBox(height: 8),
              ...thisWeek.map((a) => _PMCard(asset: a, urgency: 'thisWeek')),
              const SizedBox(height: 16),
            ],

            if (upcoming.isNotEmpty) ...[
              _sectionHeader('Upcoming', AppTheme.success),
              const SizedBox(height: 8),
              ...upcoming.map((a) => _PMCard(asset: a, urgency: 'upcoming')),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          color: color,
          margin: const EdgeInsets.only(right: 8),
        ),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}

class _PMCard extends StatelessWidget {
  final MaintenanceAsset asset;
  final String urgency;

  const _PMCard({required this.asset, required this.urgency});

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    switch (urgency) {
      case 'overdue':
        borderColor = AppTheme.danger;
        break;
      case 'thisWeek':
        borderColor = AppTheme.warning;
        break;
      default:
        borderColor = AppTheme.divider;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: borderColor, width: 3)),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${asset.tag} · ${asset.location}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.event,
                      size: 12,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${AppDateUtils.format(asset.nextPM)}',
                      style: TextStyle(
                        color: urgency == 'overdue'
                            ? AppTheme.danger
                            : AppTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: urgency == 'overdue'
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('PM scheduled for ${asset.name}')),
              );
            },
            child: const Text(
              'Schedule',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
