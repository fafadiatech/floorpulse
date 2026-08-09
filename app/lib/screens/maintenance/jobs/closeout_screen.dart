import 'package:flutter/material.dart';
import '../../../models/maintenance_job.dart';
import '../../../theme/app_theme.dart';

class CloseoutScreen extends StatefulWidget {
  final MaintenanceJob job;

  const CloseoutScreen({super.key, required this.job});

  @override
  State<CloseoutScreen> createState() => _CloseoutScreenState();
}

class _CloseoutScreenState extends State<CloseoutScreen> {
  final _faultCodeController = TextEditingController();
  final _rootCauseController = TextEditingController();
  final _remarksController = TextEditingController();
  bool _photoAttached = false;
  bool _hasHandoverSignature = false;
  bool _isClosed = false;

  @override
  void initState() {
    super.initState();
    if (widget.job.faultCode != null)
      _faultCodeController.text = widget.job.faultCode!;
    if (widget.job.rootCause != null)
      _rootCauseController.text = widget.job.rootCause!;
    if (widget.job.remarks != null)
      _remarksController.text = widget.job.remarks!;
    _hasHandoverSignature = widget.job.hasHandoverSignature;
    _isClosed = widget.job.status == MaintenanceJobStatus.closed;
  }

  @override
  void dispose() {
    _faultCodeController.dispose();
    _rootCauseController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _simulateHandover() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Handover Signature',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.divider),
              ),
              child: const Center(
                child: Text(
                  'Signature area\n(tap to simulate)',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Handover to: Production Supervisor',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
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
              setState(() => _hasHandoverSignature = true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Handover signature captured')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Confirm Signature',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _closeWorkOrder() {
    if (_faultCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a fault code before closing'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }
    if (_rootCauseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter root cause before closing'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Close Work Order',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Are you sure you want to close this work order? This action cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary),
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
              setState(() {
                widget.job.status = MaintenanceJobStatus.closed;
                widget.job.closedAt = DateTime.now();
                widget.job.faultCode = _faultCodeController.text;
                widget.job.rootCause = _rootCauseController.text;
                widget.job.remarks = _remarksController.text;
                widget.job.hasHandoverSignature = _hasHandoverSignature;
                if (widget.job.lotoStatus == LotoStatus.applied) {
                  widget.job.lotoStatus = LotoStatus.removed;
                }
                _isClosed = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Work order closed successfully'),
                  backgroundColor: AppTheme.success,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.success,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Close Work Order',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Close-Out',
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
            // Info card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.job.assetName,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.job.workOrderNo,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Fault code
            _SectionLabel('Fault Code *'),
            const SizedBox(height: 8),
            TextField(
              controller: _faultCodeController,
              enabled: !_isClosed,
              decoration: const InputDecoration(
                hintText: 'e.g. FC-HYD-02',
                prefixIcon: Icon(
                  Icons.code_outlined,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Root cause
            _SectionLabel('Root Cause *'),
            const SizedBox(height: 8),
            TextField(
              controller: _rootCauseController,
              enabled: !_isClosed,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Describe the root cause of the failure...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            // Remarks
            _SectionLabel('Remarks / Observations'),
            const SizedBox(height: 8),
            TextField(
              controller: _remarksController,
              enabled: !_isClosed,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Additional observations, recommendations...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),

            // Photo attachment
            _SectionLabel('Photo Evidence'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _isClosed
                  ? null
                  : () {
                      setState(() => _photoAttached = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Photo captured and attached (simulated)',
                          ),
                        ),
                      );
                    },
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: _photoAttached
                      ? AppTheme.success.withValues(alpha: 0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _photoAttached ? AppTheme.success : AppTheme.divider,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _photoAttached
                          ? Icons.check_circle
                          : Icons.add_a_photo_outlined,
                      color: _photoAttached
                          ? AppTheme.success
                          : AppTheme.textSecondary,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _photoAttached ? 'Photo attached' : 'Tap to attach photo',
                      style: TextStyle(
                        color: _photoAttached
                            ? AppTheme.success
                            : AppTheme.textSecondary,
                        fontSize: 14,
                        fontWeight: _photoAttached
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Handover signature
            _SectionLabel('Handover Signature'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _isClosed ? null : _simulateHandover,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _hasHandoverSignature
                      ? AppTheme.success.withValues(alpha: 0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _hasHandoverSignature
                        ? AppTheme.success
                        : AppTheme.divider,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _hasHandoverSignature ? Icons.draw : Icons.draw_outlined,
                      color: _hasHandoverSignature
                          ? AppTheme.success
                          : AppTheme.textSecondary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _hasHandoverSignature
                                ? 'Handover Signed'
                                : 'Get Handover Signature',
                            style: TextStyle(
                              color: _hasHandoverSignature
                                  ? AppTheme.success
                                  : AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Production Supervisor confirmation',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!_hasHandoverSignature && !_isClosed)
                      const Icon(
                        Icons.chevron_right,
                        color: AppTheme.textSecondary,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Close button
            if (!_isClosed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _closeWorkOrder,
                  icon: const Icon(Icons.task_alt),
                  label: const Text(
                    'Close Work Order',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.success.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: AppTheme.success),
                    SizedBox(width: 8),
                    Text(
                      'Work Order Closed',
                      style: TextStyle(
                        color: AppTheme.success,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
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
