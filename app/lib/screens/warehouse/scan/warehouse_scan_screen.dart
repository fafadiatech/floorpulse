import 'package:flutter/material.dart';
import '../../../data/warehouse_mock_data.dart';
import '../../../theme/app_theme.dart';
import '../grn/grn_list_screen.dart';
import '../stock/stock_screen.dart';
import '../stock/bin_contents_screen.dart';

class WarehouseScanScreen extends StatelessWidget {
  const WarehouseScanScreen({super.key});

  void _showScanDialog(
    BuildContext context,
    String type,
    VoidCallback onScanned,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Scan $type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.divider),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      size: 48,
                      color: AppTheme.textSecondary,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Camera preview',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Point camera at barcode/QR code',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onScanned();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Simulate Scan'),
          ),
        ],
      ),
    );
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
            // Scanner viewport
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
                    const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            size: 64,
                            color: Colors.white54,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Tap an option below to scan',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Corner indicators
                    Positioned(top: 16, left: 16, child: _Corner()),
                    Positioned(top: 16, right: 16, child: _Corner(flipH: true)),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: _Corner(flipV: true),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: _Corner(flipH: true, flipV: true),
                    ),
                  ],
                ),
              ),
            ),

            // Options
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
                            onTap: () =>
                                _showScanDialog(context, 'Barcode', () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const GRNListScreen(),
                                    ),
                                  );
                                }),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ScanOption(
                            icon: Icons.shelves,
                            label: 'Scan Bin',
                            sublabel: 'View contents',
                            onTap: () =>
                                _showScanDialog(context, 'Bin Label', () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BinContentsScreen(
                                        bin: WarehouseMockData.bins.first,
                                      ),
                                    ),
                                  );
                                }),
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
                        onTap: () =>
                            _showScanDialog(context, 'Item Barcode', () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const StockScreen(),
                                ),
                              );
                            }),
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
  final VoidCallback onTap;
  const _ScanOption({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.onTap,
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
