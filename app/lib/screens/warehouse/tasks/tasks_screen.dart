import 'package:flutter/material.dart';
import '../../../data/warehouse_mock_data.dart';
import '../../../models/warehouse_task.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/date_utils.dart';
import '../grn/grn_list_screen.dart';
import '../put_away/put_away_list_screen.dart';
import '../issue/issue_list_screen.dart';
import '../pick/pick_list_screen.dart';
import '../cycle_count/cycle_count_list_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  WarehouseTaskType? _filter;

  List<WarehouseTask> get _filtered {
    if (_filter == null) return WarehouseMockData.tasks;
    return WarehouseMockData.tasks.where((t) => t.type == _filter).toList();
  }

  void _navigateToType(WarehouseTaskType type) {
    final screen = switch (type) {
      WarehouseTaskType.grn => const GRNListScreen(),
      WarehouseTaskType.putAway => const PutAwayListScreen(),
      WarehouseTaskType.issue => const IssueListScreen(),
      WarehouseTaskType.pick => const PickListScreen(),
      WarehouseTaskType.cycleCount => const CycleCountListScreen(),
    };
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _filtered;
    final overdueCount = tasks
        .where((t) => t.status == WarehouseTaskStatus.overdue)
        .length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          if (overdueCount > 0)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.danger,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$overdueCount overdue',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: _filter == null,
                    onTap: () => setState(() => _filter = null),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'GRN',
                    selected: _filter == WarehouseTaskType.grn,
                    onTap: () =>
                        setState(() => _filter = WarehouseTaskType.grn),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Put-away',
                    selected: _filter == WarehouseTaskType.putAway,
                    onTap: () =>
                        setState(() => _filter = WarehouseTaskType.putAway),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Issue',
                    selected: _filter == WarehouseTaskType.issue,
                    onTap: () =>
                        setState(() => _filter = WarehouseTaskType.issue),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Pick',
                    selected: _filter == WarehouseTaskType.pick,
                    onTap: () =>
                        setState(() => _filter = WarehouseTaskType.pick),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Count',
                    selected: _filter == WarehouseTaskType.cycleCount,
                    onTap: () =>
                        setState(() => _filter = WarehouseTaskType.cycleCount),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: AppTheme.divider),
          Expanded(
            child: tasks.isEmpty
                ? const Center(
                    child: Text(
                      'No tasks',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tasks.length,
                    itemBuilder: (_, i) {
                      final task = tasks[i];
                      final isOverdue =
                          task.status == WarehouseTaskStatus.overdue;
                      return GestureDetector(
                        onTap: () => _navigateToType(task.type),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isOverdue
                                  ? AppTheme.danger.withValues(alpha: 0.3)
                                  : AppTheme.divider,
                            ),
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
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _typeColor(
                                    task.type,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  _typeIcon(task.type),
                                  color: _typeColor(task.type),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          task.referenceNumber,
                                          style: const TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 11,
                                          ),
                                        ),
                                        const Spacer(),
                                        _statusBadge(task.status),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      task.description,
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      task.detail ?? '',
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.schedule,
                                          size: 11,
                                          color: isOverdue
                                              ? AppTheme.danger
                                              : AppTheme.textSecondary,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          isOverdue
                                              ? 'Overdue · ${AppDateUtils.format(task.dueDate)}'
                                              : AppDateUtils.format(
                                                  task.dueDate,
                                                ),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isOverdue
                                                ? AppTheme.danger
                                                : AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.chevron_right,
                                color: AppTheme.textSecondary,
                                size: 20,
                              ),
                            ],
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

  Color _typeColor(WarehouseTaskType type) => switch (type) {
    WarehouseTaskType.grn => AppTheme.primary,
    WarehouseTaskType.putAway => AppTheme.success,
    WarehouseTaskType.issue => AppTheme.warning,
    WarehouseTaskType.pick => const Color(0xFF9C27B0),
    WarehouseTaskType.cycleCount => AppTheme.danger,
  };

  IconData _typeIcon(WarehouseTaskType type) => switch (type) {
    WarehouseTaskType.grn => Icons.local_shipping_outlined,
    WarehouseTaskType.putAway => Icons.shelves,
    WarehouseTaskType.issue => Icons.output_outlined,
    WarehouseTaskType.pick => Icons.shopping_cart_outlined,
    WarehouseTaskType.cycleCount => Icons.calculate_outlined,
  };

  Widget _statusBadge(WarehouseTaskStatus status) {
    final (label, color) = switch (status) {
      WarehouseTaskStatus.pending => ('Pending', AppTheme.warning),
      WarehouseTaskStatus.inProgress => ('In Progress', AppTheme.primary),
      WarehouseTaskStatus.overdue => ('Overdue', AppTheme.danger),
      WarehouseTaskStatus.completed => ('Done', AppTheme.success),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? AppTheme.primary : Colors.transparent,
        border: Border.all(
          color: selected ? AppTheme.primary : AppTheme.divider,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : AppTheme.textSecondary,
          fontSize: 13,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    ),
  );
}
