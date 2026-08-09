import 'package:flutter/material.dart';
import '../../../data/sales_mock_data.dart';
import '../../../models/sales_order.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/date_utils.dart';
import 'so_detail_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  SOStatus? _filter;

  List<SalesOrder> get _filtered {
    if (_filter == null) return SalesMockData.salesOrders;
    return SalesMockData.salesOrders.where((o) => o.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final orders = _filtered;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Orders')),
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
                  _Chip(
                    label: 'All',
                    selected: _filter == null,
                    onTap: () => setState(() => _filter = null),
                  ),
                  const SizedBox(width: 8),
                  _Chip(
                    label: 'Draft',
                    selected: _filter == SOStatus.draft,
                    onTap: () => setState(() => _filter = SOStatus.draft),
                  ),
                  const SizedBox(width: 8),
                  _Chip(
                    label: 'Confirmed',
                    selected: _filter == SOStatus.confirmed,
                    onTap: () => setState(() => _filter = SOStatus.confirmed),
                  ),
                  const SizedBox(width: 8),
                  _Chip(
                    label: 'In Production',
                    selected: _filter == SOStatus.inProduction,
                    onTap: () =>
                        setState(() => _filter = SOStatus.inProduction),
                  ),
                  const SizedBox(width: 8),
                  _Chip(
                    label: 'Dispatched',
                    selected: _filter == SOStatus.dispatched,
                    onTap: () => setState(() => _filter = SOStatus.dispatched),
                  ),
                  const SizedBox(width: 8),
                  _Chip(
                    label: 'Delivered',
                    selected: _filter == SOStatus.delivered,
                    onTap: () => setState(() => _filter = SOStatus.delivered),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: AppTheme.divider),
          Expanded(
            child: orders.isEmpty
                ? const Center(
                    child: Text(
                      'No orders',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (_, i) {
                      final o = orders[i];
                      final (statusColor, statusLabel) = _soStatus(o.status);
                      final isUrgent =
                          o.status == SOStatus.confirmed &&
                          o.expectedDelivery
                                  .difference(DateTime.now())
                                  .inDays <=
                              3;
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SODetailScreen(order: o),
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: isUrgent
                                ? Border.all(
                                    color: AppTheme.warning.withValues(
                                      alpha: 0.4,
                                    ),
                                  )
                                : Border.all(color: AppTheme.divider),
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
                                    o.soNumber,
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  _badge(statusLabel, statusColor),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                o.customerName,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${o.lines.length} items · ₹${_fmt(o.totalAmount)}',
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.local_shipping_outlined,
                                        size: 11,
                                        color: isUrgent
                                            ? AppTheme.warning
                                            : AppTheme.textSecondary,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        AppDateUtils.format(o.expectedDelivery),
                                        style: TextStyle(
                                          color: isUrgent
                                              ? AppTheme.warning
                                              : AppTheme.textSecondary,
                                          fontSize: 11,
                                          fontWeight: isUrgent
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (o.balance > 0) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Balance: ₹${_fmt(o.balance)}',
                                  style: const TextStyle(
                                    color: AppTheme.danger,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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

  (Color, String) _soStatus(SOStatus s) => switch (s) {
    SOStatus.draft => (AppTheme.textSecondary, 'Draft'),
    SOStatus.confirmed => (AppTheme.primary, 'Confirmed'),
    SOStatus.inProduction => (AppTheme.warning, 'In Production'),
    SOStatus.dispatched => (AppTheme.success, 'Dispatched'),
    SOStatus.delivered => (AppTheme.success, 'Delivered'),
    SOStatus.cancelled => (AppTheme.danger, 'Cancelled'),
  };

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      border: Border.all(color: color, width: 1),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
    ),
  );

  String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({
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
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    ),
  );
}
