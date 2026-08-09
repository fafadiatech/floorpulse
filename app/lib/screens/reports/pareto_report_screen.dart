import 'package:flutter/material.dart';
import '../../data/qc_mock_data.dart';
import '../../theme/app_theme.dart';

class ParetoReportScreen extends StatelessWidget {
  const ParetoReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final defects = QCMockData.paretoDefects;
    final maxCount = (defects.first['count'] as int).toDouble();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Pareto – Defect Analysis')),
      body: Column(
        children: [
          // Summary bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _SummaryChip(label: 'Total Defects', value: '53'),
                const SizedBox(width: 12),
                _SummaryChip(label: 'Period', value: 'Last 30 Days'),
                const SizedBox(width: 12),
                _SummaryChip(label: 'Types', value: '${defects.length}'),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.divider),

          // Ranked list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: defects.length,
              itemBuilder: (context, index) {
                final d = defects[index];
                final count = d['count'] as int;
                final pct = d['pct'] as double;
                final cum = d['cum'] as double;
                final barFraction = count / maxCount;

                // Fade from full primary to alpha 0.3 across ranks
                final opacity = 1.0 - (index / defects.length) * 0.7;

                return Container(
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
                          // Rank badge
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(
                                alpha: opacity * 0.15,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '#${index + 1}',
                              style: TextStyle(
                                color: AppTheme.primary.withValues(
                                  alpha: opacity,
                                ),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              d['defect'] as String,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          // Count + pct
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$count',
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${pct.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Proportional bar
                      LayoutBuilder(
                        builder: (ctx, constraints) {
                          return Stack(
                            children: [
                              Container(
                                height: 6,
                                width: constraints.maxWidth,
                                decoration: BoxDecoration(
                                  color: AppTheme.divider,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              Container(
                                height: 6,
                                width: constraints.maxWidth * barFraction,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(
                                    alpha: opacity,
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.background,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppTheme.divider),
                          ),
                          child: Text(
                            'Cum: ${cum.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryChip({required this.label, required this.value});

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
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
