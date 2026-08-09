import 'package:flutter/material.dart';
import '../../../models/customer_visit.dart';
import '../../../theme/app_theme.dart';

class CheckInScreen extends StatefulWidget {
  final CustomerVisit visit;
  const CheckInScreen({super.key, required this.visit});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _notesController = TextEditingController();
  String? _selectedOutcome;
  bool _checkingIn = false;
  bool _checkingOut = false;

  static const _outcomes = [
    'Order Placed',
    'Follow-up Required',
    'Demo Done',
    'No Interest',
    'Left Message',
  ];

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.visit.notes ?? '';
    _selectedOutcome = widget.visit.outcome;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _checkIn() async {
    setState(() => _checkingIn = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    widget.visit.status = VisitStatus.checkedIn;
    widget.visit.checkInTime = DateTime.now();
    setState(() {
      _checkingIn = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Checked in at ${widget.visit.customerName}'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _checkOut() async {
    if (_selectedOutcome == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an outcome before checking out'),
        ),
      );
      return;
    }
    setState(() => _checkingOut = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    widget.visit.status = VisitStatus.completed;
    widget.visit.checkOutTime = DateTime.now();
    widget.visit.notes = _notesController.text;
    widget.visit.outcome = _selectedOutcome;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Visit at ${widget.visit.customerName} completed'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.visit;
    final isScheduled = v.status == VisitStatus.scheduled;
    final isCheckedIn = v.status == VisitStatus.checkedIn;
    final isCompleted = v.status == VisitStatus.completed;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Visit Check-in')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _statusColor(v.status).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _statusColor(v.status).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _statusIcon(v.status),
                    color: _statusColor(v.status),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _statusLabel(v.status),
                        style: TextStyle(
                          color: _statusColor(v.status),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (v.checkInTime != null)
                        Text(
                          'Checked in at ${_fmtTime(v.checkInTime!)}',
                          style: TextStyle(
                            color: _statusColor(
                              v.status,
                            ).withValues(alpha: 0.8),
                            fontSize: 11,
                          ),
                        ),
                      if (v.checkOutTime != null)
                        Text(
                          'Checked out at ${_fmtTime(v.checkOutTime!)}',
                          style: TextStyle(
                            color: _statusColor(
                              v.status,
                            ).withValues(alpha: 0.8),
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Customer card
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
                    v.customerName,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        v.city,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16, color: AppTheme.divider),
                  _Row(label: 'Scheduled', value: _fmtTime(v.scheduledAt)),
                  _Row(label: 'Purpose', value: v.purpose),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // GPS simulation
            if (isScheduled) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.my_location,
                      color: AppTheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Location will be recorded on check-in',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _checkingIn ? null : _checkIn,
                  icon: _checkingIn
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.login),
                  label: Text(
                    _checkingIn ? 'Recording location…' : 'Check In',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
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
                ),
              ),
            ],

            if (isCheckedIn) ...[
              const Text(
                'Visit Notes',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText:
                      'Add notes about this visit – discussion, products, feedback…',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Outcome',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _outcomes.map((o) {
                  final sel = _selectedOutcome == o;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedOutcome = o),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: sel ? AppTheme.primary : Colors.white,
                        border: Border.all(
                          color: sel ? AppTheme.primary : AppTheme.divider,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        o,
                        style: TextStyle(
                          color: sel ? Colors.white : AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _checkingOut ? null : _checkOut,
                  icon: _checkingOut
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.logout),
                  label: Text(
                    _checkingOut ? 'Saving…' : 'Check Out & Complete',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],

            if (isCompleted) ...[
              const Text(
                'Visit Notes',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              if (v.notes != null && v.notes!.isNotEmpty)
                Text(
                  v.notes!,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                )
              else
                const Text(
                  'No notes recorded.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              if (v.outcome != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'Outcome: ',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        v.outcome!,
                        style: const TextStyle(
                          color: AppTheme.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(VisitStatus s) => switch (s) {
    VisitStatus.scheduled => AppTheme.warning,
    VisitStatus.checkedIn => AppTheme.primary,
    VisitStatus.completed => AppTheme.success,
    VisitStatus.missed => AppTheme.danger,
  };

  IconData _statusIcon(VisitStatus s) => switch (s) {
    VisitStatus.scheduled => Icons.schedule,
    VisitStatus.checkedIn => Icons.login,
    VisitStatus.completed => Icons.check_circle,
    VisitStatus.missed => Icons.cancel,
  };

  String _statusLabel(VisitStatus s) => switch (s) {
    VisitStatus.scheduled => 'Scheduled',
    VisitStatus.checkedIn => 'In Progress',
    VisitStatus.completed => 'Completed',
    VisitStatus.missed => 'Missed',
  };

  String _fmtTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
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
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}
