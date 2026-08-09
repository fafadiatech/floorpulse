import 'package:flutter/material.dart';
import '../../../models/purchase_order.dart';
import '../../../theme/app_theme.dart';
import 'grn_review_screen.dart';

class _BatchEntry {
  final String lineNo;
  final String itemCode;
  final String description;
  final String unit;
  final double orderedQty;
  final TextEditingController batchCtrl;
  final TextEditingController qtyCtrl;

  _BatchEntry({
    required this.lineNo,
    required this.itemCode,
    required this.description,
    required this.unit,
    required this.orderedQty,
  }) : batchCtrl = TextEditingController(),
       qtyCtrl = TextEditingController();

  void dispose() {
    batchCtrl.dispose();
    qtyCtrl.dispose();
  }
}

class GRNBatchEntryScreen extends StatefulWidget {
  final PurchaseOrder po;
  const GRNBatchEntryScreen({super.key, required this.po});

  @override
  State<GRNBatchEntryScreen> createState() => _GRNBatchEntryScreenState();
}

class _GRNBatchEntryScreenState extends State<GRNBatchEntryScreen> {
  late final List<_BatchEntry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = widget.po.lines
        .map(
          (l) => _BatchEntry(
            lineNo: l.lineNo,
            itemCode: l.itemCode,
            description: l.description,
            unit: l.unit,
            orderedQty: l.orderedQty,
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    for (final e in _entries) {
      e.dispose();
    }
    super.dispose();
  }

  void _simulateScan(int index) {
    final e = _entries[index];
    setState(() {
      e.batchCtrl.text = 'BT-2024-0${90 + index}';
      e.qtyCtrl.text = e.orderedQty.toStringAsFixed(0);
    });
  }

  void _proceed() {
    // Build review data
    final reviewLines = _entries.map((e) {
      final received = double.tryParse(e.qtyCtrl.text) ?? 0;
      return {
        'lineNo': e.lineNo,
        'itemCode': e.itemCode,
        'description': e.description,
        'unit': e.unit,
        'orderedQty': e.orderedQty,
        'receivedQty': received,
        'batch': e.batchCtrl.text,
      };
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GRNReviewScreen(po: widget.po, lines: reviewLines),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text('Receive – ${widget.po.poNumber}')),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(
                  Icons.local_shipping_outlined,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.po.supplier,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_entries.length} lines',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.divider),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _entries.length,
              itemBuilder: (_, i) => _LineEntryCard(
                entry: _entries[i],
                onSimulate: () => _simulateScan(i),
                onChanged: () => setState(() {}),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _proceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Review & Submit',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineEntryCard extends StatelessWidget {
  final _BatchEntry entry;
  final VoidCallback onSimulate;
  final VoidCallback onChanged;

  const _LineEntryCard({
    required this.entry,
    required this.onSimulate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
              Text(
                entry.itemCode,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'Ordered: ${entry.orderedQty.toStringAsFixed(0)} ${entry.unit}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            entry.description,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: entry.batchCtrl,
                  onChanged: (_) => onChanged(),
                  decoration: const InputDecoration(
                    labelText: 'Batch / Serial No.',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onSimulate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                  foregroundColor: AppTheme.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Icon(Icons.qr_code_scanner, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: entry.qtyCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => onChanged(),
            decoration: InputDecoration(
              labelText: 'Received Qty',
              suffixText: entry.unit,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
