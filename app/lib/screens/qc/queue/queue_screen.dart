import 'package:flutter/material.dart';
import '../../../data/qc_mock_data.dart';
import '../../../models/inspection_item.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/date_utils.dart';
import 'inspection_detail_screen.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('Inspection Queue'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Incoming'),
              Tab(text: 'In-Process'),
              Tab(text: 'Final'),
            ],
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primary,
            labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
        body: TabBarView(
          children: [
            _QueueTab(items: QCMockData.incomingItems),
            _QueueTab(items: QCMockData.inProcessItems),
            _QueueTab(items: QCMockData.finalItems),
          ],
        ),
      ),
    );
  }
}

class _QueueTab extends StatelessWidget {
  final List<InspectionItem> items;

  const _QueueTab({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.checklist, size: 48, color: AppTheme.textSecondary),
            SizedBox(height: 12),
            Text(
              'No items in queue',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) => _InspectionCard(
        item: items[index],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InspectionDetailScreen(item: items[index]),
          ),
        ),
      ),
    );
  }
}

class _InspectionCard extends StatelessWidget {
  final InspectionItem item;
  final VoidCallback onTap;

  const _InspectionCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
                Text(
                  item.referenceNumber,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                _statusBadge(item.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              item.productName,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (item.supplier != null)
              _InfoRow(
                icon: Icons.local_shipping_outlined,
                text: item.supplier!,
              ),
            if (item.workCenter != null)
              _InfoRow(
                icon: Icons.precision_manufacturing_outlined,
                text: item.workCenter!,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                _InfoRow(
                  icon: Icons.inventory_2_outlined,
                  text: 'Qty: ${item.quantity}',
                ),
                const Spacer(),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: item.isOverdue
                      ? AppTheme.danger
                      : AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  AppDateUtils.format(item.dueDate),
                  style: TextStyle(
                    color: item.isOverdue
                        ? AppTheme.danger
                        : AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: item.isOverdue
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}
