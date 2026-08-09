import 'package:flutter/material.dart';
import '../../../models/capa.dart';
import '../../../models/ncr.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/date_utils.dart';

class CAPAScreen extends StatefulWidget {
  final CAPA? capa;
  final NCR? ncr;
  final bool createMode;

  const CAPAScreen({super.key, this.capa, this.ncr, required this.createMode});

  @override
  State<CAPAScreen> createState() => _CAPAScreenState();
}

class _CAPAScreenState extends State<CAPAScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rootCauseController = TextEditingController();
  final _correctiveController = TextEditingController();
  final _preventiveController = TextEditingController();
  final _ownerController = TextEditingController();
  final _dueDateController = TextEditingController();

  late CAPAStatus _status;

  @override
  void initState() {
    super.initState();
    if (!widget.createMode && widget.capa != null) {
      _status = widget.capa!.status;
    } else {
      _status = CAPAStatus.open;
      final due = DateTime.now().add(const Duration(days: 30));
      _dueDateController.text = AppDateUtils.format(due);
    }
  }

  @override
  void dispose() {
    _rootCauseController.dispose();
    _correctiveController.dispose();
    _preventiveController.dispose();
    _ownerController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  void _submitCapa() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('CAPA raised successfully')));
  }

  void _closeCapa() {
    setState(() => _status = CAPAStatus.closed);
    if (widget.capa != null) widget.capa!.status = CAPAStatus.closed;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('CAPA marked as closed')));
  }

  Color _statusColor(CAPAStatus s) {
    switch (s) {
      case CAPAStatus.open:
        return AppTheme.warning;
      case CAPAStatus.inProgress:
        return AppTheme.primary;
      case CAPAStatus.closed:
        return AppTheme.success;
      case CAPAStatus.overdue:
        return AppTheme.danger;
    }
  }

  String _statusLabel(CAPAStatus s) {
    switch (s) {
      case CAPAStatus.open:
        return 'Open';
      case CAPAStatus.inProgress:
        return 'In Progress';
      case CAPAStatus.closed:
        return 'Closed';
      case CAPAStatus.overdue:
        return 'Overdue';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(widget.createMode ? 'Raise CAPA' : 'CAPA Detail'),
      ),
      body: widget.createMode ? _buildCreateForm() : _buildViewMode(),
    );
  }

  Widget _buildCreateForm() {
    return Column(
      children: [
        Expanded(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (widget.ncr != null) ...[
                  _contextCard(),
                  const SizedBox(height: 16),
                ],
                _label('Root Cause *'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _rootCauseController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Describe the root cause of the non-conformance',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                _label('Corrective Action *'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _correctiveController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Immediate action to correct the non-conformance',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                _label('Preventive Action *'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _preventiveController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Actions to prevent recurrence',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                _label('Assign Owner *'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _ownerController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Anil Mehta (Supplier Quality)',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                _label('Due Date'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _dueDateController,
                  decoration: const InputDecoration(hintText: 'Due date'),
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
              onPressed: _submitCapa,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Submit CAPA',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewMode() {
    final c = widget.capa!;
    final statusColor = _statusColor(_status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.circle, size: 10, color: statusColor),
                const SizedBox(width: 8),
                Text(
                  _statusLabel(_status),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  c.capaNumber,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ViewRow(label: 'Owner', value: c.owner),
                _ViewRow(
                  label: 'Due Date',
                  value: AppDateUtils.format(c.dueDate),
                  valueColor: _status == CAPAStatus.overdue
                      ? AppTheme.danger
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _SectionCard(title: 'Root Cause', content: c.rootCause),
          const SizedBox(height: 12),
          _SectionCard(title: 'Corrective Action', content: c.correctiveAction),
          const SizedBox(height: 12),
          _SectionCard(title: 'Preventive Action', content: c.preventiveAction),
          const SizedBox(height: 24),

          if (_status != CAPAStatus.closed)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _closeCapa,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.success,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Mark as Closed',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _contextCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.report_problem_outlined,
            color: AppTheme.danger,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${widget.ncr!.ncrNumber} · ${widget.ncr!.defectType}',
              style: const TextStyle(
                color: AppTheme.danger,
                fontSize: 13,
                fontWeight: FontWeight.w500,
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

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: child,
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String content;

  const _SectionCard({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _ViewRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
