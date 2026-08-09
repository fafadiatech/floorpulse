import 'package:flutter/material.dart';
import '../../../data/warehouse_mock_data.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/date_utils.dart';
import 'cycle_count_screen.dart';

class CycleCountListScreen extends StatelessWidget {
  const CycleCountListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final counts = WarehouseMockData.cycleCounts;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Cycle Counts')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: counts.length,
        itemBuilder: (_, i) {
          final cc = counts[i];
          final isOverdue = cc['status'] == 'Overdue';
          final dueDate = cc['dueDate'] as DateTime;
          final lines = cc['lines'] as List;

          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CycleCountScreen(cycleCount: cc),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        cc['ccNumber'] as String,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      _badge(
                        cc['status'] as String,
                        isOverdue ? AppTheme.danger : AppTheme.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cc['zone'] as String,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 12,
                        color: isOverdue
                            ? AppTheme.danger
                            : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOverdue
                            ? 'Overdue – was due ${AppDateUtils.format(dueDate)}'
                            : 'Due ${AppDateUtils.format(dueDate)}',
                        style: TextStyle(
                          color: isOverdue
                              ? AppTheme.danger
                              : AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 12,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${lines.length} items',
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
          );
        },
      ),
    );
  }

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      border: Border.all(color: color, width: 1.1),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
    ),
  );
}
