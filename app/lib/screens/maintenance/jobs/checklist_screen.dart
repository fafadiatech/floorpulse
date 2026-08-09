import 'package:flutter/material.dart';
import '../../../models/maintenance_job.dart';
import '../../../theme/app_theme.dart';

class ChecklistScreen extends StatefulWidget {
  final MaintenanceJob job;

  const ChecklistScreen({super.key, required this.job});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  late List<ChecklistItem> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.job.checklist;
  }

  int get _checkedCount => _items.where((i) => i.isChecked).length;
  double get _progress => _items.isEmpty ? 0.0 : _checkedCount / _items.length;

  @override
  Widget build(BuildContext context) {
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
          'Checklist',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (_progress == 1.0)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                Icons.check_circle,
                color: AppTheme.success,
                size: 24,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress: $_checkedCount / ${_items.length} tasks',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${(_progress * 100).toInt()}%',
                      style: TextStyle(
                        color: _progress == 1.0
                            ? AppTheme.success
                            : AppTheme.primary,
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
                    value: _progress,
                    backgroundColor: AppTheme.divider,
                    color: _progress == 1.0
                        ? AppTheme.success
                        : AppTheme.primary,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.divider),

          // Checklist items
          Expanded(
            child: _items.isEmpty
                ? const Center(
                    child: Text(
                      'No checklist items for this job',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            item.isChecked = !item.isChecked;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: item.isChecked
                                  ? AppTheme.success.withValues(alpha: 0.4)
                                  : AppTheme.divider,
                              width: 1.2,
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
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: item.isChecked
                                      ? AppTheme.success
                                      : AppTheme.background,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: item.isChecked
                                        ? AppTheme.success
                                        : AppTheme.textSecondary.withValues(
                                            alpha: 0.4,
                                          ),
                                    width: 1.5,
                                  ),
                                ),
                                child: item.isChecked
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.task,
                                  style: TextStyle(
                                    color: item.isChecked
                                        ? AppTheme.textSecondary
                                        : AppTheme.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    decoration: item.isChecked
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                              Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Bottom action
          if (_progress == 1.0)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.success,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'All checklist tasks completed!',
                        style: TextStyle(
                          color: AppTheme.success,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
