import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'packing_screen.dart';

class PickExecutionScreen extends StatefulWidget {
  final Map<String, dynamic> pickList;
  const PickExecutionScreen({super.key, required this.pickList});

  @override
  State<PickExecutionScreen> createState() => _PickExecutionScreenState();
}

class _PickExecutionScreenState extends State<PickExecutionScreen> {
  late List<bool> _picked;

  @override
  void initState() {
    super.initState();
    final lines = widget.pickList['lines'] as List;
    _picked = lines.map((l) => l['picked'] == true).toList();
  }

  int get _pickedCount => _picked.where((v) => v).length;

  void _pick(int index) => setState(() => _picked[index] = true);

  @override
  Widget build(BuildContext context) {
    final pl = widget.pickList;
    final lines = pl['lines'] as List;
    final allPicked = _pickedCount == lines.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text(pl['plNumber'] as String)),
      body: Column(
        children: [
          // Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pl['doNumber'] as String,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  pl['customer'] as String,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Pick from bins as directed below',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$_pickedCount / ${lines.length} picked',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: lines.isEmpty ? 0 : _pickedCount / lines.length,
                    minHeight: 5,
                    backgroundColor: AppTheme.divider,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.divider),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lines.length,
              itemBuilder: (_, i) {
                final line = lines[i] as Map<String, dynamic>;
                final done = _picked[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: done
                        ? AppTheme.success.withValues(alpha: 0.04)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: done
                          ? AppTheme.success.withValues(alpha: 0.3)
                          : AppTheme.divider,
                    ),
                    boxShadow: done
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  line['itemCode'] as String,
                                  style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(
                                      alpha: 0.08,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.shelves,
                                        size: 10,
                                        color: AppTheme.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        line['bin'] as String,
                                        style: const TextStyle(
                                          color: AppTheme.primary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              line['description'] as String,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Qty: ${(line['qty'] as double).toStringAsFixed(0)} ${line['unit']}',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      done
                          ? const Icon(
                              Icons.check_circle,
                              color: AppTheme.success,
                              size: 28,
                            )
                          : ElevatedButton(
                              onPressed: () => _pick(i),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Pick',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: allPicked
                    ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PackingScreen(pickList: pl),
                        ),
                      )
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.success,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  disabledBackgroundColor: AppTheme.divider,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  allPicked
                      ? 'Proceed to Packing'
                      : 'Pick all items to continue',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
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
