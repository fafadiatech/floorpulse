import 'package:flutter/material.dart';
import '../../../models/sales_approval.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/date_utils.dart';

class ApprovalDetailScreen extends StatefulWidget {
  final SalesApproval approval;
  const ApprovalDetailScreen({super.key, required this.approval});

  @override
  State<ApprovalDetailScreen> createState() => _ApprovalDetailScreenState();
}

class _ApprovalDetailScreenState extends State<ApprovalDetailScreen> {
  final _remarksController = TextEditingController();
  final _valueController = TextEditingController();
  bool _acting = false;

  @override
  void initState() {
    super.initState();
    _valueController.text = widget.approval.requestedValue.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _remarksController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _act(bool approve) async {
    setState(() => _acting = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    widget.approval.status = approve
        ? ApprovalStatus.approved
        : ApprovalStatus.rejected;
    widget.approval.remarks = _remarksController.text.isNotEmpty
        ? _remarksController.text
        : null;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.approval.title} – ${approve ? 'Approved' : 'Rejected'}',
        ),
        backgroundColor: approve ? AppTheme.success : AppTheme.danger,
      ),
    );
  }

  String _typeLabel(ApprovalType t) => switch (t) {
    ApprovalType.discountOverride => 'Discount Override',
    ApprovalType.creditLimitOverride => 'Credit Limit Override',
    ApprovalType.specialTerm => 'Special Payment Term',
    ApprovalType.returnApproval => 'Return Approval',
  };

  Color _statusColor(ApprovalStatus s) => switch (s) {
    ApprovalStatus.pending => AppTheme.warning,
    ApprovalStatus.approved => AppTheme.success,
    ApprovalStatus.rejected => AppTheme.danger,
  };

  @override
  Widget build(BuildContext context) {
    final ap = widget.approval;
    final isPending = ap.status == ApprovalStatus.pending;
    final statusColor = _statusColor(ap.status);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Approval Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    isPending
                        ? Icons.pending_actions
                        : (ap.status == ApprovalStatus.approved
                              ? Icons.check_circle
                              : Icons.cancel),
                    color: statusColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isPending
                        ? 'Awaiting your approval'
                        : (ap.status == ApprovalStatus.approved
                              ? 'Approved'
                              : 'Rejected'),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Detail card
            Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ap.title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _typeLabel(ap.type),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const Divider(height: 20, color: AppTheme.divider),
                  _InfoRow(label: 'Customer', value: ap.customerName),
                  if (ap.soNumber != null)
                    _InfoRow(label: 'Sales Order', value: ap.soNumber!),
                  _InfoRow(label: 'Requested By', value: ap.requestedBy),
                  _InfoRow(
                    label: 'Requested At',
                    value: AppDateUtils.format(ap.requestedAt),
                  ),
                  _InfoRow(
                    label: 'Requested Value',
                    value: _fmtValue(ap.type, ap.requestedValue),
                  ),
                  if (ap.approvedValue != null)
                    _InfoRow(
                      label: 'Approved Value',
                      value: _fmtValue(ap.type, ap.approvedValue!),
                      valueColor: AppTheme.success,
                    ),
                  const Divider(height: 20, color: AppTheme.divider),
                  const Text(
                    'Details',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ap.details,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  if (ap.remarks != null) ...[
                    const Divider(height: 20, color: AppTheme.divider),
                    const Text(
                      'Remarks',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ap.remarks!,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (isPending) ...[
              const SizedBox(height: 20),
              const Text(
                'Approved Value',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _valueController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter approved value',
                  prefixText: ap.type == ApprovalType.discountOverride
                      ? ''
                      : '₹ ',
                  suffixText: ap.type == ApprovalType.discountOverride
                      ? '%'
                      : null,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Remarks (optional)',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _remarksController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Add remarks for the requester',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _acting ? null : () => _act(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.danger,
                        side: const BorderSide(color: AppTheme.danger),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Reject',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _acting ? null : () => _act(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _acting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Approve',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _fmtValue(ApprovalType type, double v) {
    if (type == ApprovalType.discountOverride)
      return '${v.toStringAsFixed(0)}%';
    if (type == ApprovalType.specialTerm)
      return 'Net ${v.toStringAsFixed(0)} days';
    return '₹${(v / 1000).toStringAsFixed(0)}K';
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _InfoRow({required this.label, required this.value, this.valueColor});

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
            style: TextStyle(
              color: valueColor ?? AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
