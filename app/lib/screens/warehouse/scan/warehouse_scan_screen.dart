import 'package:flutter/material.dart';
import '../../../api/scan_navigator.dart';
import '../../../theme/app_theme.dart';

class WarehouseScanScreen extends StatefulWidget {
  const WarehouseScanScreen({super.key});

  @override
  State<WarehouseScanScreen> createState() => _WarehouseScanScreenState();
}

class _WarehouseScanScreenState extends State<WarehouseScanScreen> {
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
        title: const Text('Scan', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.6),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.qr_code_scanner,
                            size: 64,
                            color: Colors.white54,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Enter a barcode, PO, bin, or item code',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ScanCodeField(
                            controller: _codeController,
                            onSubmit: _submit,
                          ),
                        ],
                      ),
                    ),
                    const Positioned(top: 16, left: 16, child: _Corner()),
                    const Positioned(
                      top: 16,
                      right: 16,
                      child: _Corner(flipH: true),
                    ),
                    const Positioned(
                      bottom: 16,
                      left: 16,
                      child: _Corner(flipV: true),
                    ),
                    const Positioned(
                      bottom: 16,
                      right: 16,
                      child: _Corner(flipH: true, flipV: true),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _ScanOption(
                            icon: Icons.local_shipping_outlined,
                            label: 'Scan GRN / PO',
                            sublabel: 'Receive goods',
                            onTap: _busy ? null : _submit,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ScanOption(
                            icon: Icons.shelves,
                            label: 'Scan Bin',
                            sublabel: 'View contents',
                            onTap: _busy ? null : _submit,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: _ScanOption(
                        icon: Icons.inventory_2_outlined,
                        label: 'Scan Item / Batch',
                        sublabel: 'Check stock across all bins',
                        onTap: _busy ? null : _submit,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final bool flipH;
  final bool flipV;
  const _Corner({this.flipH = false, this.flipV = false});

  @override
  Widget build(BuildContext context) => Transform.scale(
    scaleX: flipH ? -1 : 1,
    scaleY: flipV ? -1 : 1,
    child: SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(painter: _CornerPainter()),
    ),
  );
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ScanOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback? onTap;
  const _ScanOption({
    required this.icon,
    required this.label,
    required this.sublabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  sublabel,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
