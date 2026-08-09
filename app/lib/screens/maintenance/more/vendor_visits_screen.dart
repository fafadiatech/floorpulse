import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/date_utils.dart';

class VendorVisitsScreen extends StatelessWidget {
  const VendorVisitsScreen({super.key});

  // Mock vendor visits
  static final List<Map<String, dynamic>> _visits = [
    {
      'vendor': 'Precision Bearings Ltd.',
      'purpose': 'Annual service – Grinding Cell bearings',
      'contact': 'Rajesh Gupta',
      'date': DateTime.now().add(const Duration(days: 3)),
      'status': 'Scheduled',
      'statusColor': AppTheme.primary,
    },
    {
      'vendor': 'Atlas Copco Service',
      'purpose': 'Compressor overhaul – CMP-UR-005',
      'contact': 'Vikram Singh',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'status': 'Completed',
      'statusColor': AppTheme.success,
    },
    {
      'vendor': 'Fanuc India Pvt. Ltd.',
      'purpose': 'Robot servo drive replacement – ROB-B5-006',
      'contact': 'Sunil Patel',
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'status': 'Completed',
      'statusColor': AppTheme.success,
    },
    {
      'vendor': 'Bosch Rexroth',
      'purpose': 'Hydraulic system inspection – HYD-LA-002',
      'contact': 'Amit Kumar',
      'date': DateTime.now().add(const Duration(days: 10)),
      'status': 'Scheduled',
      'statusColor': AppTheme.primary,
    },
  ];

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
          'Vendor Visits',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Schedule vendor visit — coming soon'),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _visits.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final visit = _visits[index];
          final visitDate = visit['date'] as DateTime;
          final isUpcoming = visitDate.isAfter(DateTime.now());

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(
                  color: visit['statusColor'] as Color,
                  width: 3,
                ),
              ),
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
                    Expanded(
                      child: Text(
                        visit['vendor'] as String,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: (visit['statusColor'] as Color).withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: visit['statusColor'] as Color,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        visit['status'] as String,
                        style: TextStyle(
                          color: visit['statusColor'] as Color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  visit['purpose'] as String,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 13,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      visit['contact'] as String,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppDateUtils.format(visitDate),
                      style: TextStyle(
                        color: isUpcoming
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: isUpcoming
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
