import 'package:flutter/material.dart';
import '../../../models/purchase_order.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/date_utils.dart';
import 'grn_batch_entry_screen.dart';

class GRNDetailScreen extends StatelessWidget {
  final PurchaseOrder po;
  const GRNDetailScreen({super.key, required this.po});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text(po.poNumber)),
      body: Column(
        children: [
          // PO Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  po.supplier,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.person_outline,
                      label: po.buyerContact,
                    ),
                    const SizedBox(width: 12),
                    _InfoChip(
                      icon: Icons.schedule,
                      label: AppDateUtils.format(po.expectedDate),
                      color: po.expectedDate.isBefore(DateTime.now())
                          ? AppTheme.danger
                          : AppTheme.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.divider),

          // Line items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: po.lines.length,
              itemBuilder: (_, i) {
                final line = po.lines[i];
                final pct = line.orderedQty == 0
                    ? 0.0
                    : (line.receivedQty / line.orderedQty).clamp(0.0, 1.0);
                final isExcess = line.receivedQty > line.orderedQty;
                final progressColor = isExcess
                    ? AppTheme.danger
                    : line.isFullyReceived
                    ? AppTheme.success
                    : AppTheme.primary;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
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
                            line.lineNo,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            line.itemCode,
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        line.description,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            '${line.receivedQty.toStringAsFixed(0)} / ${line.orderedQty.toStringAsFixed(0)} ${line.unit}',
                            style: TextStyle(
                              color: progressColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          if (isExcess)
                            _badge('Excess', AppTheme.danger)
                          else if (line.isFullyReceived)
                            _badge('Complete', AppTheme.success)
                          else if (line.isPartial)
                            _badge('Partial', AppTheme.warning)
                          else
                            _badge('Pending', AppTheme.textSecondary),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 5,
                          backgroundColor: AppTheme.divider,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progressColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Start receiving button
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GRNBatchEntryScreen(po: po),
                  ),
                ),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text(
                  'Start Receiving',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({
    required this.icon,
    required this.label,
    this.color = AppTheme.textSecondary,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(color: color, fontSize: 12)),
    ],
  );
}
