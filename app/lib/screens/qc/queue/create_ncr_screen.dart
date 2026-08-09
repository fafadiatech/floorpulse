import 'package:flutter/material.dart';
import '../../../models/inspection_item.dart';
import '../../../theme/app_theme.dart';

class CreateNCRScreen extends StatefulWidget {
  final InspectionItem item;

  const CreateNCRScreen({super.key, required this.item});

  @override
  State<CreateNCRScreen> createState() => _CreateNCRScreenState();
}

class _CreateNCRScreenState extends State<CreateNCRScreen> {
  final _formKey = GlobalKey<FormState>();
  final _defectTypeController = TextEditingController();
  final _qtyRejectedController = TextEditingController();
  final _notesController = TextEditingController();
  String _severity = 'Major';
  String _disposition = 'Rework';

  final List<String> _severities = ['Minor', 'Major', 'Critical'];
  final List<String> _dispositions = [
    'Rework',
    'Scrap',
    'Accept As-Is',
    'Return to Supplier',
  ];

  @override
  void dispose() {
    _defectTypeController.dispose();
    _qtyRejectedController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // Pop back past verdict + evidence + reading + detail to queue
    Navigator.popUntil(context, (route) => route.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('NCR raised for ${widget.item.referenceNumber}'),
        backgroundColor: AppTheme.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Raise NCR')),
      body: Column(
        children: [
          // Context strip
          Container(
            color: AppTheme.danger.withValues(alpha: 0.08),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(
                  Icons.report_problem_outlined,
                  size: 16,
                  color: AppTheme.danger,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.item.referenceNumber} · ${widget.item.productName}',
                    style: const TextStyle(
                      color: AppTheme.danger,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _label('Defect Type *'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _defectTypeController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Dimensional Out-of-Spec',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  _label('Quantity Rejected *'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _qtyRejectedController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Enter quantity',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (int.tryParse(v) == null) return 'Must be a number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _label('Severity *'),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _severity,
                        isExpanded: true,
                        items: _severities
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _severity = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _label('Disposition *'),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _disposition,
                        isExpanded: true,
                        items: _dispositions
                            .map(
                              (d) => DropdownMenuItem(value: d, child: Text(d)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _disposition = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _label('Notes'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Additional details (optional)',
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
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
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.danger,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Submit NCR',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
