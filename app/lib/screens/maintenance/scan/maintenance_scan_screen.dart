import 'package:flutter/material.dart';
import '../../../api/scan_navigator.dart';
import '../../../theme/app_theme.dart';

class MaintenanceScanScreen extends StatefulWidget {
  const MaintenanceScanScreen({super.key});

  @override
  State<MaintenanceScanScreen> createState() => _MaintenanceScanScreenState();
}

class _MaintenanceScanScreenState extends State<MaintenanceScanScreen> {
  final _codeController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await resolveAndOpenScan(context, _codeController.text);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: const Text(
          'Maintenance Scan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Enter an asset tag, job, or part code',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ScanCodeField(controller: _codeController, onSubmit: _submit),
              const SizedBox(height: 24),
              _ScanOption(
                icon: Icons.precision_manufacturing_outlined,
                title: 'Asset QR Scan',
                subtitle:
                    'Scan asset tag to view details, log breakdown or start PM',
                onScan: _busy ? null : _submit,
              ),
              const SizedBox(height: 16),
              _ScanOption(
                icon: Icons.build_circle_outlined,
                title: 'Job QR Scan',
                subtitle:
                    'Scan work order QR to jump directly into job execution',
                onScan: _busy ? null : _submit,
              ),
              const SizedBox(height: 16),
              _ScanOption(
                icon: Icons.inventory_2_outlined,
                title: 'Part Label Scan',
                subtitle:
                    'Scan spare part barcode for spares lookup or job consumption',
                onScan: _busy ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onScan;

  const _ScanOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onScan,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Scan',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
