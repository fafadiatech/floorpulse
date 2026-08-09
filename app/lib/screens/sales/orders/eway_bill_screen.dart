import 'package:flutter/material.dart';
import '../../../models/sales_order.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/date_utils.dart';

class EWayBillScreen extends StatelessWidget {
  final SalesOrder order;
  final String dnNumber;
  const EWayBillScreen({
    super.key,
    required this.order,
    required this.dnNumber,
  });

  @override
  Widget build(BuildContext context) {
    final ewbNumber = '232400${order.soNumber.split('-').last}';
    final validUntil = DateTime.now().add(const Duration(days: 3));
    final isActive =
        order.status == SOStatus.dispatched ||
        order.status == SOStatus.delivered;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('E-way Bill')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.success.withValues(alpha: 0.1)
                    : AppTheme.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: (isActive ? AppTheme.success : AppTheme.warning)
                      .withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isActive ? Icons.check_circle : Icons.pending_outlined,
                    color: isActive ? AppTheme.success : AppTheme.warning,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isActive ? 'E-way Bill Active' : 'E-way Bill Not Generated',
                    style: TextStyle(
                      color: isActive ? AppTheme.success : AppTheme.warning,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // EWB card
            Container(
              width: double.infinity,
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
                      const Text(
                        'E-way Bill',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            'Valid',
                            style: TextStyle(
                              color: AppTheme.success,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Divider(height: 20, color: AppTheme.divider),
                  if (isActive) ...[
                    // EWB Number display
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'EWB Number',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ewbNumber,
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  _InfoRow(label: 'Document No.', value: dnNumber),
                  _InfoRow(
                    label: 'Document Date',
                    value: AppDateUtils.format(DateTime.now()),
                  ),
                  _InfoRow(label: 'From', value: 'Nashik, MH (27)'),
                  _InfoRow(
                    label: 'To',
                    value: order.deliveryAddress.split(',').last.trim(),
                  ),
                  _InfoRow(
                    label: 'Transporter',
                    value: isActive ? 'Speed Logistics · TR27AAAA1234' : '—',
                  ),
                  _InfoRow(
                    label: 'Vehicle No.',
                    value: isActive ? 'MH-04-BV-2210' : '—',
                  ),
                  _InfoRow(
                    label: 'Distance',
                    value: isActive ? '~320 km' : '—',
                  ),
                  _InfoRow(
                    label: 'Valid Until',
                    value: isActive ? AppDateUtils.format(validUntil) : '—',
                  ),
                  const Divider(height: 20, color: AppTheme.divider),
                  _InfoRow(
                    label: 'Total Value',
                    value: '₹${_fmt(order.totalAmount)}',
                  ),
                  _InfoRow(
                    label: 'CGST (9%)',
                    value: '₹${_fmt(order.totalAmount * 0.09)}',
                  ),
                  _InfoRow(
                    label: 'SGST (9%)',
                    value: '₹${_fmt(order.totalAmount * 0.09)}',
                  ),
                  _InfoRow(
                    label: 'Invoice Value',
                    value: '₹${_fmt(order.totalAmount * 1.18)}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                if (isActive) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('EWB PDF sent to printer'),
                            ),
                          ),
                      icon: const Icon(Icons.print_outlined, size: 18),
                      label: const Text('Print'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: const BorderSide(color: AppTheme.divider),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('EWB shared via WhatsApp'),
                            ),
                          ),
                      icon: const Icon(Icons.share_outlined, size: 18),
                      label: const Text(
                        'Share',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'E-way Bill generation requires dispatch status',
                              ),
                            ),
                          ),
                      icon: const Icon(Icons.article_outlined),
                      label: const Text(
                        'Generate EWB',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}
