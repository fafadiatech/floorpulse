import 'package:flutter/material.dart';
import '../../../data/qc_mock_data.dart';
import '../../../theme/app_theme.dart';
import '../../qc/queue/inspection_detail_screen.dart';
import 'traceability_tree_screen.dart';

class QCScanScreen extends StatelessWidget {
  const QCScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('QC Scan', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Select scan type to begin inspection',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              _ScanOptionCard(
                icon: Icons.local_shipping_outlined,
                title: 'GRN QR Scan',
                subtitle: 'Scan incoming goods receipt for incoming inspection',
                onSimulate: () {
                  final item = QCMockData.incomingItems.first;
                  _showScanAnimation(context, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InspectionDetailScreen(item: item),
                      ),
                    );
                  });
                },
              ),
              const SizedBox(height: 16),

              _ScanOptionCard(
                icon: Icons.work_outline,
                title: 'Job Card QR Scan',
                subtitle: 'Scan in-process job card for in-process inspection',
                onSimulate: () {
                  final item = QCMockData.inProcessItems.first;
                  _showScanAnimation(context, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InspectionDetailScreen(item: item),
                      ),
                    );
                  });
                },
              ),
              const SizedBox(height: 16),

              _ScanOptionCard(
                icon: Icons.qr_code_scanner,
                title: 'Batch / Serial Scan',
                subtitle:
                    'Trace a batch or serial number through the supply chain',
                onSimulate: () {
                  _showScanAnimation(context, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TraceabilityTreeScreen(),
                      ),
                    );
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showScanAnimation(BuildContext context, VoidCallback onComplete) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ScanningDialog(),
    );

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (context.mounted) {
        Navigator.pop(context); // dismiss dialog
        onComplete();
      }
    });
  }
}

class _ScanOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onSimulate;

  const _ScanOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onSimulate,
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
            onPressed: onSimulate,
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

class _ScanningDialog extends StatelessWidget {
  const _ScanningDialog();

  @override
  Widget build(BuildContext context) {
    return const Dialog(
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Scanning…',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
