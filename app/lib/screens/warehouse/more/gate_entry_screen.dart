import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class GateEntryScreen extends StatefulWidget {
  const GateEntryScreen({super.key});

  @override
  State<GateEntryScreen> createState() => _GateEntryScreenState();
}

class _GateEntryScreenState extends State<GateEntryScreen> {
  final _vehicleController = TextEditingController();
  final _driverController = TextEditingController();
  final _supplierController = TextEditingController();
  final _remarksController = TextEditingController();
  String _purpose = 'Delivery';
  bool _submitting = false;

  static const _purposes = [
    'Delivery',
    'Collection',
    'Service',
    'Visitor',
    'Empty Return',
  ];

  @override
  void dispose() {
    _vehicleController.dispose();
    _driverController.dispose();
    _supplierController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_vehicleController.text.isEmpty || _supplierController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in vehicle number and supplier/party'),
        ),
      );
      return;
    }
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    final gateNo = 'GE-${DateTime.now().millisecondsSinceEpoch % 10000}';
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Gate entry $gateNo logged for ${_vehicleController.text}',
        ),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Gate Entry')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: AppTheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Entry Time',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        _formatNow(),
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _Label('Vehicle Number'),
            const SizedBox(height: 6),
            TextField(
              controller: _vehicleController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                hintText: 'e.g. MH-04-AB-1234',
                prefixIcon: Icon(
                  Icons.local_shipping_outlined,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            _Label('Driver Name'),
            const SizedBox(height: 6),
            TextField(
              controller: _driverController,
              decoration: const InputDecoration(
                hintText: 'Enter driver name',
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            _Label('Supplier / Party'),
            const SizedBox(height: 6),
            TextField(
              controller: _supplierController,
              decoration: const InputDecoration(
                hintText: 'Enter supplier or party name',
                prefixIcon: Icon(
                  Icons.business_outlined,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            _Label('Purpose'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _purposes.map((p) {
                final sel = _purpose == p;
                return GestureDetector(
                  onTap: () => setState(() => _purpose = p),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
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
                      p,
                      style: TextStyle(
                        color: sel ? Colors.white : AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            _Label('Remarks (optional)'),
            const SizedBox(height: 6),
            TextField(
              controller: _remarksController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Any notes about this entry',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  _submitting ? 'Logging Entry…' : 'Log Gate Entry',
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
        ),
      ),
    );
  }

  String _formatNow() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}  $h:$m';
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: AppTheme.textPrimary,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
  );
}
