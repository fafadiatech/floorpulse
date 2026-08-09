import 'package:flutter/material.dart';
import '../../../data/qc_mock_data.dart';
import '../../../models/inspection_item.dart';
import '../../../models/reading_parameter.dart';
import '../../../theme/app_theme.dart';
import 'evidence_screen.dart';

class ReadingEntryScreen extends StatefulWidget {
  final InspectionItem item;

  const ReadingEntryScreen({super.key, required this.item});

  @override
  State<ReadingEntryScreen> createState() => _ReadingEntryScreenState();
}

class _ReadingEntryScreenState extends State<ReadingEntryScreen> {
  late final List<ReadingParameter> _parameters;
  final Map<String, TextEditingController> _measureControllers = {};
  final Map<String, bool?> _checkResults = {};
  final Map<String, TextEditingController> _noteControllers = {};

  @override
  void initState() {
    super.initState();
    _parameters = QCMockData.parametersFor(widget.item.type);
    for (final p in _parameters) {
      if (p.type == ParameterType.measurement) {
        _measureControllers[p.id] = TextEditingController();
      }
      _noteControllers[p.id] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _measureControllers.values) {
      c.dispose();
    }
    for (final c in _noteControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  bool? _specStatus(ReadingParameter p) {
    final controller = _measureControllers[p.id];
    if (controller == null || controller.text.isEmpty) return null;
    final value = double.tryParse(controller.text);
    if (value == null || p.nominalValue == null) return null;
    final upper = p.nominalValue! + (p.tolerancePlus ?? 0);
    final lower = p.nominalValue! - (p.toleranceMinus ?? 0);
    return value >= lower && value <= upper;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Reading Entry')),
      body: Column(
        children: [
          // Item reference strip
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(
                  Icons.assignment_outlined,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.item.referenceNumber,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.item.productName,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.divider),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _parameters.length,
              itemBuilder: (context, index) {
                final p = _parameters[index];
                return _ParameterCard(
                  parameter: p,
                  measureController: _measureControllers[p.id],
                  noteController: _noteControllers[p.id]!,
                  checkResult: _checkResults[p.id],
                  specStatus: p.type == ParameterType.measurement
                      ? _specStatus(p)
                      : null,
                  onCheckChanged: (val) =>
                      setState(() => _checkResults[p.id] = val),
                  onMeasureChanged: (_) => setState(() {}),
                );
              },
            ),
          ),

          // Bottom action
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EvidenceScreen(item: widget.item),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save & Continue',
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

class _ParameterCard extends StatelessWidget {
  final ReadingParameter parameter;
  final TextEditingController? measureController;
  final TextEditingController noteController;
  final bool? checkResult;
  final bool? specStatus;
  final void Function(bool?) onCheckChanged;
  final void Function(String) onMeasureChanged;

  const _ParameterCard({
    required this.parameter,
    required this.measureController,
    required this.noteController,
    required this.checkResult,
    required this.specStatus,
    required this.onCheckChanged,
    required this.onMeasureChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isMeasurement = parameter.type == ParameterType.measurement;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
          // Header
          Row(
            children: [
              Icon(
                isMeasurement ? Icons.straighten : Icons.check_box_outlined,
                size: 16,
                color: isMeasurement ? AppTheme.primary : AppTheme.success,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  parameter.name,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (isMeasurement) ...[
            // Nominal + tolerance info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Text(
                    'Nominal: ${parameter.nominalValue} ${parameter.unit ?? ''}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '+${parameter.tolerancePlus} / -${parameter.toleranceMinus}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Input row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: measureController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: onMeasureChanged,
                    decoration: InputDecoration(
                      hintText: 'Enter measured value',
                      suffixText: parameter.unit,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                if (specStatus != null) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: specStatus! ? AppTheme.success : AppTheme.danger,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      specStatus! ? 'In Spec' : 'Out of Spec',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ] else ...[
            // Checklist
            Text(
              parameter.checkDescription ?? '',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _ToggleBtn(
                  label: 'Pass',
                  icon: Icons.check,
                  selected: checkResult == true,
                  color: AppTheme.success,
                  onTap: () => onCheckChanged(true),
                ),
                const SizedBox(width: 10),
                _ToggleBtn(
                  label: 'Fail',
                  icon: Icons.close,
                  selected: checkResult == false,
                  color: AppTheme.danger,
                  onTap: () => onCheckChanged(false),
                ),
              ],
            ),
          ],

          const SizedBox(height: 10),
          TextField(
            controller: noteController,
            decoration: const InputDecoration(
              hintText: 'Notes (optional)',
              contentPadding: EdgeInsets.symmetric(
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

class _ToggleBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          border: Border.all(
            color: selected ? color : AppTheme.divider,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : AppTheme.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
