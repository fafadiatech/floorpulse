import 'package:flutter/material.dart';
import '../../../models/purchase_order.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/date_utils.dart';

class GRNLabelScreen extends StatefulWidget {
  final PurchaseOrder po;
  final List<Map<String, dynamic>> lines;

  const GRNLabelScreen({super.key, required this.po, required this.lines});

  @override
  State<GRNLabelScreen> createState() => _GRNLabelScreenState();
}

class _GRNLabelScreenState extends State<GRNLabelScreen> {
  int _selectedLabel = 0;
  bool _printing = false;

  List<Map<String, dynamic>> get _receivedLines =>
      widget.lines.where((l) => (l['receivedQty'] as double) > 0).toList();

  void _print() async {
    setState(() => _printing = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _printing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_receivedLines.length} label(s) sent to printer'),
      ),
    );
    // Pop all the way back to GRN list
    Navigator.popUntil(context, (r) => r.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'GRN-${DateTime.now().millisecondsSinceEpoch % 10000} submitted successfully',
        ),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lines = _receivedLines;
    if (lines.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(title: const Text('GRN Submitted')),
        body: const Center(
          child: Text(
            'No items received.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }
    final selected = lines[_selectedLabel];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Label Preview')),
      body: Column(
        children: [
          // Submitted banner
          Container(
            color: AppTheme.success.withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.success, size: 18),
                SizedBox(width: 8),
                Text(
                  'GRN submitted successfully',
                  style: TextStyle(
                    color: AppTheme.success,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.divider),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label selector chips
                  if (lines.length > 1) ...[
                    const Text(
                      'Select label to preview:',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: lines.asMap().entries.map((e) {
                          final active = e.key == _selectedLabel;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedLabel = e.key),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: active ? AppTheme.primary : Colors.white,
                                border: Border.all(
                                  color: active
                                      ? AppTheme.primary
                                      : AppTheme.divider,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                e.value['itemCode'] as String,
                                style: TextStyle(
                                  color: active
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Label preview card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.divider, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Label header bar
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.label_outline,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'FloorPulse · Goods Receipt Label',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                widget.po.poNumber,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Item info
                              Text(
                                selected['description'] as String,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selected['itemCode'] as String,
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Divider(
                                height: 20,
                                color: AppTheme.divider,
                              ),
                              _LabelRow(
                                label: 'Batch / Serial',
                                value: (selected['batch'] as String).isNotEmpty
                                    ? selected['batch'] as String
                                    : '—',
                              ),
                              _LabelRow(
                                label: 'Quantity',
                                value:
                                    '${(selected['receivedQty'] as double).toStringAsFixed(0)} ${selected['unit']}',
                              ),
                              _LabelRow(
                                label: 'Supplier',
                                value: widget.po.supplier,
                              ),
                              _LabelRow(
                                label: 'GRN Date',
                                value: AppDateUtils.format(DateTime.now()),
                              ),
                              _LabelRow(
                                label: 'Received By',
                                value: 'Suresh Patel – EMP-3024',
                              ),
                              const SizedBox(height: 14),
                              // Mock barcode visual
                              Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppTheme.divider),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(40, (i) {
                                    final w = [
                                      2.0,
                                      1.0,
                                      3.0,
                                      1.0,
                                      2.0,
                                      1.0,
                                      2.0,
                                      3.0,
                                    ][i % 8];
                                    return Container(
                                      width: w,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 0.5,
                                      ),
                                      color: i % 3 == 0
                                          ? Colors.transparent
                                          : AppTheme.textPrimary,
                                    );
                                  }),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Center(
                                child: Text(
                                  selected['batch'] as String,
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.popUntil(context, (r) => r.isFirst),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Skip Print'),
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
                    onPressed: _printing ? null : _print,
                    icon: _printing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.print_outlined),
                    label: Text(
                      _printing
                          ? 'Printing…'
                          : 'Print ${lines.length} Label(s)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
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
            ),
          ),
        ],
      ),
    );
  }
}

class _LabelRow extends StatelessWidget {
  final String label;
  final String value;
  const _LabelRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
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
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
