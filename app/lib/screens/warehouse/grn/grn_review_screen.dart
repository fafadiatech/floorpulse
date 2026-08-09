import 'package:flutter/material.dart';
import '../../../models/purchase_order.dart';
import '../../../theme/app_theme.dart';
import 'grn_label_screen.dart';

class GRNReviewScreen extends StatelessWidget {
  final PurchaseOrder po;
  final List<Map<String, dynamic>> lines;

  const GRNReviewScreen({super.key, required this.po, required this.lines});

  @override
  Widget build(BuildContext context) {
    final allOk = lines.every((l) => (l['receivedQty'] as double) > 0);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text('Review – ${po.poNumber}')),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_outlined,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Review received quantities before submitting',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.divider),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Column headers
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(flex: 3, child: _Head('Item')),
                      Expanded(
                        flex: 2,
                        child: _Head('Ordered', align: TextAlign.center),
                      ),
                      Expanded(
                        flex: 2,
                        child: _Head('Received', align: TextAlign.center),
                      ),
                      Expanded(
                        flex: 2,
                        child: _Head('Status', align: TextAlign.center),
                      ),
                    ],
                  ),
                ),
                ...lines.asMap().entries.map((e) {
                  final i = e.key;
                  final l = e.value;
                  final ordered = l['orderedQty'] as double;
                  final received = l['receivedQty'] as double;
                  final isLast = i == lines.length - 1;
                  final isEven = i % 2 == 0;

                  Color statusColor;
                  String statusLabel;
                  if (received == 0) {
                    statusColor = AppTheme.textSecondary;
                    statusLabel = 'Not Rcvd';
                  } else if (received > ordered) {
                    statusColor = AppTheme.danger;
                    statusLabel = 'Excess';
                  } else if (received == ordered) {
                    statusColor = AppTheme.success;
                    statusLabel = 'Match';
                  } else {
                    statusColor = AppTheme.warning;
                    statusLabel = 'Short';
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isEven ? Colors.white : AppTheme.background,
                      borderRadius: isLast
                          ? const BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            )
                          : null,
                      border: Border(
                        left: const BorderSide(color: AppTheme.divider),
                        right: const BorderSide(color: AppTheme.divider),
                        bottom: const BorderSide(color: AppTheme.divider),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l['itemCode'] as String,
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                l['description'] as String,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 11,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if ((l['batch'] as String).isNotEmpty)
                                Text(
                                  l['batch'] as String,
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${ordered.toStringAsFixed(0)}\n${l['unit']}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${received.toStringAsFixed(0)}\n${l['unit']}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                if (!allOk)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.warning.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.warning_amber_outlined,
                          color: AppTheme.warning,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Some items have zero received quantity. You can still submit — they will remain open.',
                            style: TextStyle(
                              color: AppTheme.warning,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
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
                    builder: (_) => GRNLabelScreen(po: po, lines: lines),
                  ),
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  'Submit GRN',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.success,
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
}

class _Head extends StatelessWidget {
  final String text;
  final TextAlign align;
  const _Head(this.text, {this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: align,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 11,
      fontWeight: FontWeight.w700,
    ),
  );
}
