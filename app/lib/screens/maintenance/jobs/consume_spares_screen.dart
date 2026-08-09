import 'package:flutter/material.dart';
import '../../../data/maintenance_mock_data.dart';
import '../../../models/maintenance_job.dart';
import '../../../models/spare_part.dart';
import '../../../theme/app_theme.dart';

class ConsumeSpareScreen extends StatefulWidget {
  final MaintenanceJob job;

  const ConsumeSpareScreen({super.key, required this.job});

  @override
  State<ConsumeSpareScreen> createState() => _ConsumeSpareScreenState();
}

class _ConsumeSpareScreenState extends State<ConsumeSpareScreen> {
  late List<ConsumedSpare> _consumed;

  @override
  void initState() {
    super.initState();
    _consumed = List.from(widget.job.consumedSpares);
  }

  void _showAddSpareDialog(SparePart part) {
    double qty = 1;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            part.description,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow('Part No.', part.partNo),
              const SizedBox(height: 4),
              _DetailRow('Location', part.location),
              const SizedBox(height: 4),
              _DetailRow('On Hand', '${part.qtyOnHand} ${part.unit}'),
              const SizedBox(height: 16),
              if (part.qtyOnHand == 0)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.danger.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, color: AppTheme.danger, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Out of stock — a Material Request will be raised',
                          style: TextStyle(
                            color: AppTheme.danger,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                const Text(
                  'Quantity to Consume',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (qty > 0.5) setDlgState(() => qty -= 0.5);
                      },
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: AppTheme.primary,
                      ),
                    ),
                    Container(
                      width: 80,
                      alignment: Alignment.center,
                      child: Text(
                        '$qty ${part.unit}',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (qty < part.qtyOnHand) setDlgState(() => qty += 0.5);
                      },
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (part.qtyOnHand == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Material Request raised for out-of-stock item',
                      ),
                      backgroundColor: AppTheme.warning,
                    ),
                  );
                } else {
                  setState(() {
                    _consumed.add(
                      ConsumedSpare(
                        partNo: part.partNo,
                        description: part.description,
                        qty: qty,
                        unit: part.unit,
                      ),
                    );
                    widget.job.consumedSpares.add(
                      ConsumedSpare(
                        partNo: part.partNo,
                        description: part.description,
                        qty: qty,
                        unit: part.unit,
                      ),
                    );
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${part.description} ($qty ${part.unit}) added',
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: part.qtyOnHand == 0
                    ? AppTheme.warning
                    : AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                part.qtyOnHand == 0 ? 'Raise Request' : 'Add',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spareParts = MaintenanceMockData.spareParts;

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
          'Consume Spares',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Consumed so far
            if (_consumed.isNotEmpty) ...[
              const Text(
                'Consumed in This Job',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              ...List.generate(_consumed.length, (i) {
                final c = _consumed[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppTheme.success,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.description,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              c.partNo,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${c.qty} ${c.unit}',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],

            // Available parts catalogue
            const Text(
              'Select from Parts Catalogue',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            ...spareParts.map(
              (part) => GestureDetector(
                onTap: () => _showAddSpareDialog(part),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
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
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: part.isBelowReorder
                              ? AppTheme.danger.withValues(alpha: 0.1)
                              : AppTheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.settings_outlined,
                          color: part.isBelowReorder
                              ? AppTheme.danger
                              : AppTheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              part.description,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${part.partNo} · ${part.location}',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${part.qtyOnHand} ${part.unit}',
                            style: TextStyle(
                              color: part.qtyOnHand == 0
                                  ? AppTheme.danger
                                  : part.isBelowReorder
                                  ? AppTheme.warning
                                  : AppTheme.success,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (part.isBelowReorder)
                            const Text(
                              'Low',
                              style: TextStyle(
                                color: AppTheme.warning,
                                fontSize: 10,
                              ),
                            ),
                          if (part.qtyOnHand == 0)
                            const Text(
                              'Out',
                              style: TextStyle(
                                color: AppTheme.danger,
                                fontSize: 10,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.add_circle_outline,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Scan button
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Scan part barcode to look up from catalogue',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan Part Barcode'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
