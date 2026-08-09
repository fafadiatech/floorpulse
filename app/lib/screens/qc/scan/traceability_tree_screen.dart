import 'package:flutter/material.dart';
import '../../../data/qc_mock_data.dart';
import '../../../models/traceability.dart';
import '../../../theme/app_theme.dart';
import 'stock_ledger_screen.dart';

class TraceabilityTreeScreen extends StatelessWidget {
  const TraceabilityTreeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Traceability – BT-2024-087')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Batch header
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.account_tree_outlined,
                  color: AppTheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BT-2024-087',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Hydraulic Pump Assembly – HPA-2000',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tree
          _TreeNode(node: QCMockData.traceabilityTree, depth: 0),
        ],
      ),
    );
  }
}

class _TreeNode extends StatelessWidget {
  final TraceabilityNode node;
  final int depth;

  const _TreeNode({required this.node, required this.depth});

  IconData _iconForType(String type) {
    switch (type) {
      case 'product':
        return Icons.factory_outlined;
      case 'material':
        return Icons.category_outlined;
      case 'supplier':
        return Icons.local_shipping_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'product':
        return AppTheme.primary;
      case 'material':
        return AppTheme.warning;
      case 'supplier':
        return AppTheme.success;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLeaf = node.children.isEmpty;
    final icon = _iconForType(node.type);
    final color = _colorForType(node.type);

    if (isLeaf) {
      return Padding(
        padding: EdgeInsets.only(left: depth * 20.0, bottom: 8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.label,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      node.detail,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StockLedgerScreen()),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                ),
                child: const Text('Ledger', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(left: depth * 20.0, bottom: 8),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.divider),
          ),
          child: ExpansionTile(
            initiallyExpanded: depth == 0,
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            childrenPadding: const EdgeInsets.only(
              left: 8,
              right: 8,
              bottom: 8,
            ),
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            title: Text(
              node.label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              node.detail,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
            children: node.children
                .map((child) => _TreeNode(node: child, depth: 0))
                .toList(),
          ),
        ),
      ),
    );
  }
}
