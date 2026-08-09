import 'package:flutter/material.dart';
import '../../../data/warehouse_mock_data.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/date_utils.dart';
import '../../../widgets/stat_card.dart';
import '../grn/grn_list_screen.dart';
import '../put_away/put_away_list_screen.dart';
import '../issue/issue_list_screen.dart';
import '../pick/pick_list_screen.dart';
import '../cycle_count/cycle_count_list_screen.dart';

class WarehouseDashboardScreen extends StatelessWidget {
  const WarehouseDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = WarehouseMockData.dashboardStats;
    final user = WarehouseMockData.warehouseUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.factory, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            const Text(
              'FloorPulse',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primary,
              child: Text(
                user.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
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
            // Greeting
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
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${AppDateUtils.greeting()}, ${user.name.split(' ').first}!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppDateUtils.fullDate(DateTime.now()),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warehouse_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Pending GRNs',
                    value: '${stats['pendingGRNs']}',
                    icon: Icons.local_shipping_outlined,
                    color: AppTheme.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Put-aways',
                    value: '${stats['pendingPutAways']}',
                    icon: Icons.shelves,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Issue Requests',
                    value: '${stats['issueRequests']}',
                    icon: Icons.output_outlined,
                    color: AppTheme.danger,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Counts Due',
                    value: '${stats['countsDue']}',
                    icon: Icons.fact_check_outlined,
                    color: AppTheme.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Worklist sections
            _sectionHeader('Pending Work'),
            const SizedBox(height: 12),
            _WorklistCard(
              icon: Icons.local_shipping_outlined,
              iconColor: AppTheme.warning,
              title: 'GRNs Pending',
              count: stats['pendingGRNs'] as int,
              subtitle: '1 overdue',
              subtitleColor: AppTheme.danger,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GRNListScreen()),
              ),
            ),
            const SizedBox(height: 10),
            _WorklistCard(
              icon: Icons.shelves,
              iconColor: AppTheme.primary,
              title: 'Put-aways',
              count: stats['pendingPutAways'] as int,
              subtitle: '4 items ready',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PutAwayListScreen()),
              ),
            ),
            const SizedBox(height: 10),
            _WorklistCard(
              icon: Icons.output_outlined,
              iconColor: AppTheme.danger,
              title: 'Issue Requests',
              count: stats['issueRequests'] as int,
              subtitle: '1 overdue',
              subtitleColor: AppTheme.danger,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const IssueListScreen()),
              ),
            ),
            const SizedBox(height: 10),
            _WorklistCard(
              icon: Icons.list_alt_outlined,
              iconColor: AppTheme.success,
              title: 'Pick Lists',
              count: stats['pickLists'] as int,
              subtitle: '1 in progress',
              subtitleColor: AppTheme.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PickListScreen()),
              ),
            ),
            const SizedBox(height: 10),
            _WorklistCard(
              icon: Icons.fact_check_outlined,
              iconColor: AppTheme.textSecondary,
              title: 'Counts Due',
              count: stats['countsDue'] as int,
              subtitle: '1 overdue',
              subtitleColor: AppTheme.danger,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CycleCountListScreen()),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) => Text(
    title,
    style: const TextStyle(
      color: AppTheme.textPrimary,
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
  );
}

class _WorklistCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final int count;
  final String subtitle;
  final Color? subtitleColor;
  final VoidCallback onTap;

  const _WorklistCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.count,
    required this.subtitle,
    this.subtitleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: subtitleColor ?? AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: iconColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
