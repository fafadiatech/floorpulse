import 'package:flutter/material.dart';
import '../../../models/inspection_item.dart';
import '../../../theme/app_theme.dart';
import 'create_ncr_screen.dart';

enum _Verdict { pass, conditionalAccept, reject }

class VerdictScreen extends StatefulWidget {
  final InspectionItem item;

  const VerdictScreen({super.key, required this.item});

  @override
  State<VerdictScreen> createState() => _VerdictScreenState();
}

class _VerdictScreenState extends State<VerdictScreen> {
  _Verdict? _selected;

  void _submitVerdict() {
    if (_selected == _Verdict.reject) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CreateNCRScreen(item: widget.item)),
      );
      return;
    }

    if (_selected == _Verdict.pass &&
        widget.item.type == InspectionType.finalInspection) {
      _showReleaseSheet();
      return;
    }

    // Pop all the way back to queue and confirm
    Navigator.popUntil(
      context,
      (route) => route.isFirst || _isQueueRoute(route),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _selected == _Verdict.pass
              ? 'Verdict: Pass recorded'
              : 'Verdict: Conditional Accept recorded',
        ),
      ),
    );
  }

  bool _isQueueRoute(Route route) {
    return route.settings.name == '/queue';
  }

  void _showReleaseSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                color: AppTheme.success,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Release for Dispatch',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Confirm release of ${widget.item.referenceNumber} – ${widget.item.productName} (${widget.item.quantity} units) for dispatch?',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: const BorderSide(color: AppTheme.divider),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.popUntil(context, (r) => r.isFirst);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Released for dispatch')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Release',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFinal = widget.item.type == InspectionType.finalInspection;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Verdict')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.referenceNumber,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.item.productName,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Quantity: ${widget.item.quantity} units',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        if (isFinal) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withValues(alpha: 0.1),
                              border: Border.all(
                                color: AppTheme.success,
                                width: 1.2,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Final Inspection – Pass enables Dispatch',
                              style: TextStyle(
                                color: AppTheme.success,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Select Verdict',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _VerdictOption(
                    verdict: _Verdict.pass,
                    selected: _selected,
                    icon: Icons.check_circle_outline,
                    label: 'Pass',
                    description: 'All parameters within specification.',
                    color: AppTheme.success,
                    onTap: () => setState(() => _selected = _Verdict.pass),
                  ),
                  const SizedBox(height: 10),
                  _VerdictOption(
                    verdict: _Verdict.conditionalAccept,
                    selected: _selected,
                    icon: Icons.warning_amber_outlined,
                    label: 'Conditional Accept',
                    description: 'Minor deviation; accepted with waiver.',
                    color: AppTheme.warning,
                    onTap: () =>
                        setState(() => _selected = _Verdict.conditionalAccept),
                  ),
                  const SizedBox(height: 10),
                  _VerdictOption(
                    verdict: _Verdict.reject,
                    selected: _selected,
                    icon: Icons.cancel_outlined,
                    label: 'Reject',
                    description: 'Non-conformance found. Raise NCR.',
                    color: AppTheme.danger,
                    onTap: () => setState(() => _selected = _Verdict.reject),
                  ),
                ],
              ),
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
                onPressed: _selected == null ? null : _submitVerdict,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selected == _Verdict.reject
                      ? AppTheme.danger
                      : _selected == _Verdict.pass && isFinal
                      ? AppTheme.success
                      : AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  disabledBackgroundColor: AppTheme.divider,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _selected == _Verdict.reject
                      ? 'Raise NCR'
                      : _selected == _Verdict.pass && isFinal
                      ? 'Release for Dispatch'
                      : 'Submit Verdict',
                  style: const TextStyle(
                    fontSize: 16,
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

class _VerdictOption extends StatelessWidget {
  final _Verdict verdict;
  final _Verdict? selected;
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _VerdictOption({
    required this.verdict,
    required this.selected,
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == verdict;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppTheme.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
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
            Icon(
              icon,
              color: isSelected ? color : AppTheme.textSecondary,
              size: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? color : AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 22),
          ],
        ),
      ),
    );
  }
}
