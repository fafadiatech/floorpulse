import 'package:flutter/material.dart';
import '../../../models/sales_order.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/date_utils.dart';
import 'work_order_screen.dart';

class FulfilmentTimelineScreen extends StatelessWidget {
  final SalesOrder order;
  const FulfilmentTimelineScreen({super.key, required this.order});

  List<_TimelineStep> _buildSteps() {
    final od = order.orderDate;
    final ed = order.expectedDelivery;
    final status = order.status;

    int idx = switch (status) {
      SOStatus.draft => 0,
      SOStatus.confirmed => 1,
      SOStatus.inProduction => 3,
      SOStatus.dispatched => 5,
      SOStatus.delivered => 7,
      SOStatus.cancelled => -1,
    };

    return [
      _TimelineStep(
        label: 'Order Placed',
        date: AppDateUtils.format(od),
        done: idx >= 0,
      ),
      _TimelineStep(
        label: 'Order Confirmed',
        date: AppDateUtils.format(od.add(const Duration(hours: 2))),
        done: idx >= 1,
      ),
      _TimelineStep(
        label: 'Work Order Raised',
        date: AppDateUtils.format(od.add(const Duration(days: 1))),
        done: idx >= 2,
        hasLink: order.workOrderRef != null,
      ),
      _TimelineStep(
        label: 'In Production',
        date: AppDateUtils.format(od.add(const Duration(days: 2))),
        done: idx >= 3,
      ),
      _TimelineStep(
        label: 'QC Passed',
        date: AppDateUtils.format(od.add(const Duration(days: 8))),
        done: idx >= 4,
      ),
      _TimelineStep(
        label: 'Packed & Ready',
        date: AppDateUtils.format(od.add(const Duration(days: 9))),
        done: idx >= 5,
      ),
      _TimelineStep(
        label: 'Dispatched',
        date: idx >= 5
            ? AppDateUtils.format(od.add(const Duration(days: 10)))
            : AppDateUtils.format(ed),
        done: idx >= 5,
      ),
      _TimelineStep(
        label: 'Delivered',
        date: AppDateUtils.format(ed),
        done: idx >= 7,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps();
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Fulfilment Timeline')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
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
                  Text(
                    order.soNumber,
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    order.customerName,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Expected delivery: ${AppDateUtils.format(order.expectedDelivery)}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Timeline',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            ...steps.asMap().entries.map((entry) {
              final i = entry.key;
              final step = entry.value;
              final isLast = i == steps.length - 1;
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline indicator
                    Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: step.done
                                ? AppTheme.success
                                : AppTheme.divider,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            step.done ? Icons.check : Icons.circle_outlined,
                            color: step.done
                                ? Colors.white
                                : AppTheme.textSecondary,
                            size: 16,
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: step.done
                                  ? AppTheme.success.withValues(alpha: 0.3)
                                  : AppTheme.divider,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: step.done
                                ? AppTheme.success.withValues(alpha: 0.05)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: step.done
                                  ? AppTheme.success.withValues(alpha: 0.25)
                                  : AppTheme.divider,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      step.label,
                                      style: TextStyle(
                                        color: step.done
                                            ? AppTheme.textPrimary
                                            : AppTheme.textSecondary,
                                        fontSize: 13,
                                        fontWeight: step.done
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (step.hasLink)
                                    TextButton.icon(
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => WorkOrderScreen(
                                            workOrderRef: order.workOrderRef!,
                                            order: order,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.open_in_new,
                                        size: 13,
                                      ),
                                      label: const Text(
                                        'View WO',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppTheme.primary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 0,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                ],
                              ),
                              Text(
                                step.date,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _TimelineStep {
  final String label, date;
  final bool done;
  final bool hasLink;
  const _TimelineStep({
    required this.label,
    required this.date,
    required this.done,
    this.hasLink = false,
  });
}
