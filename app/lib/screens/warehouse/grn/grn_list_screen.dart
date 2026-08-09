import 'package:flutter/material.dart';
import '../../../data/warehouse_mock_data.dart';
import '../../../models/purchase_order.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/date_utils.dart';
import 'grn_detail_screen.dart';

class GRNListScreen extends StatelessWidget {
  const GRNListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pos = WarehouseMockData.purchaseOrders;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('GRNs Pending')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pos.length,
        itemBuilder: (context, i) => _POCard(
          po: pos[i],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => GRNDetailScreen(po: pos[i])),
          ),
        ),
      ),
    );
  }
}

class _POCard extends StatelessWidget {
  final PurchaseOrder po;
  final VoidCallback onTap;
  const _POCard({required this.po, required this.onTap});

  Color get _statusColor {
    switch (po.status) {
      case POStatus.pending:
        return AppTheme.warning;
      case POStatus.partialGRN:
        return AppTheme.primary;
      case POStatus.received:
        return AppTheme.success;
      case POStatus.closed:
        return AppTheme.textSecondary;
    }
  }

  String get _statusLabel {
    switch (po.status) {
      case POStatus.pending:
        return 'Pending';
      case POStatus.partialGRN:
        return 'Partial GRN';
      case POStatus.received:
        return 'Received';
      case POStatus.closed:
        return 'Closed';
    }
  }

  bool get _isOverdue => po.expectedDate.isBefore(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.07),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    po.poNumber,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  _badge(_statusLabel, _statusColor),
                  if (_isOverdue) ...[
                    const SizedBox(width: 6),
                    _badge('Overdue', AppTheme.danger),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    po.supplier,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.view_list_outlined,
                        size: 13,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${po.lines.length} line items',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.schedule,
                        size: 13,
                        color: _isOverdue
                            ? AppTheme.danger
                            : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppDateUtils.format(po.expectedDate),
                        style: TextStyle(
                          color: _isOverdue
                              ? AppTheme.danger
                              : AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: _isOverdue
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
