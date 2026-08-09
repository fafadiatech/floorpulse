import 'package:flutter/material.dart';
import '../../../data/qc_mock_data.dart';
import '../../../models/traceability.dart';
import '../../../theme/app_theme.dart';

class StockLedgerScreen extends StatelessWidget {
  final String? itemCode;
  final String? description;
  final List<StockLedgerEntry>? entries;

  const StockLedgerScreen({
    super.key,
    this.itemCode,
    this.description,
    this.entries,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedEntries = entries ?? QCMockData.stockLedger;
    final title = itemCode != null
        ? 'Stock Ledger – $itemCode'
        : 'Stock Ledger – BT-2024-087';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary card
          Container(
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
              children: [
                if (itemCode != null) ...[
                  _SummaryRow(label: 'Item', value: itemCode!),
                  const Divider(height: 16, color: AppTheme.divider),
                  if (description != null) ...[
                    _SummaryRow(label: 'Description', value: description!),
                    const Divider(height: 16, color: AppTheme.divider),
                  ],
                ] else ...[
                  const _SummaryRow(label: 'Batch', value: 'BT-2024-087'),
                  const Divider(height: 16, color: AppTheme.divider),
                  const _SummaryRow(
                    label: 'Product',
                    value: 'Hydraulic Pump Assembly – HPA-2000',
                  ),
                  const Divider(height: 16, color: AppTheme.divider),
                ],
                _SummaryRow(
                  label: 'Current Balance',
                  value:
                      '${resolvedEntries.last.balance.toStringAsFixed(0)} ${resolvedEntries.last.unit}',
                  valueColor: AppTheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Movement History',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          // Column headers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: _HeaderCell('Date')),
                Expanded(flex: 3, child: _HeaderCell('Type')),
                Expanded(
                  flex: 2,
                  child: _HeaderCell('Qty', align: TextAlign.right),
                ),
                Expanded(
                  flex: 2,
                  child: _HeaderCell('Balance', align: TextAlign.right),
                ),
                Expanded(flex: 3, child: _HeaderCell('Reference')),
              ],
            ),
          ),

          // Rows
          ...resolvedEntries.asMap().entries.map((entry) {
            final i = entry.key;
            final e = entry.value;
            final isLast = i == resolvedEntries.length - 1;
            final isEven = i % 2 == 0;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  bottom: isLast
                      ? const BorderSide(color: AppTheme.divider)
                      : const BorderSide(color: AppTheme.divider),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      e.date,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Expanded(flex: 3, child: _MovementChip(type: e.movementType)),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${e.quantity > 0 ? '+' : ''}${e.quantity.toStringAsFixed(0)}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: e.quantity > 0
                            ? AppTheme.success
                            : AppTheme.danger,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      e.balance.toStringAsFixed(0),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      e.reference,
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final TextAlign align;

  const _HeaderCell(this.text, {this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _MovementChip extends StatelessWidget {
  final String type;

  const _MovementChip({required this.type});

  Color _color() {
    switch (type) {
      case 'GRN':
        return AppTheme.success;
      case 'Issue':
        return AppTheme.danger;
      case 'Transfer':
        return AppTheme.primary;
      default:
        return AppTheme.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
