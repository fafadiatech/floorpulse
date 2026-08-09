import 'package:flutter/material.dart';
import '../../../data/warehouse_mock_data.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/date_utils.dart';
import 'pick_execution_screen.dart';

class PickListScreen extends StatelessWidget {
  const PickListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lists = WarehouseMockData.pickLists;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Pick Lists')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: lists.length,
        itemBuilder: (_, i) {
          final pl = lists[i];
          final lines = pl['lines'] as List;
          final pickedLines = lines.where((l) => l['picked'] == true).length;
          final isInProgress = pl['status'] == 'In Progress';
          final dispatchDate = pl['dispatchDate'] as DateTime;
          final isUrgent = dispatchDate.difference(DateTime.now()).inHours < 4;

          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PickExecutionScreen(pickList: pl),
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
                        pl['plNumber'] as String,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      _badge(
                        pl['status'] as String,
                        isInProgress ? AppTheme.primary : AppTheme.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pl['doNumber'] as String,
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    pl['customer'] as String,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isInProgress) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: lines.isEmpty ? 0 : pickedLines / lines.length,
                        minHeight: 4,
                        backgroundColor: AppTheme.divider,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 12,
                        color: isUrgent
                            ? AppTheme.danger
                            : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Dispatch by ${AppDateUtils.format(dispatchDate)}',
                        style: TextStyle(
                          color: isUrgent
                              ? AppTheme.danger
                              : AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.view_list_outlined,
                        size: 12,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isInProgress
                            ? '$pickedLines / ${lines.length} picked'
                            : '${lines.length} lines',
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
