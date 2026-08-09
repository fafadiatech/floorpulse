import 'package:flutter/material.dart';
import '../../../data/warehouse_mock_data.dart';
import '../../../models/warehouse_bin.dart';
import '../../../theme/app_theme.dart';
import 'bin_contents_screen.dart';

class WarehouseBrowserScreen extends StatefulWidget {
  const WarehouseBrowserScreen({super.key});

  @override
  State<WarehouseBrowserScreen> createState() => _WarehouseBrowserScreenState();
}

class _WarehouseBrowserScreenState extends State<WarehouseBrowserScreen> {
  String? _selectedZone;

  List<WarehouseBin> get _zoneBins {
    if (_selectedZone == null) return [];
    return WarehouseMockData.bins
        .where((b) => b.binCode.startsWith(_selectedZone!))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final zones = WarehouseMockData.zones;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Warehouse Browser'),
        leading: _selectedZone != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedZone = null),
              )
            : null,
      ),
      body: _selectedZone == null ? _buildZoneList(zones) : _buildBinList(),
    );
  }

  Widget _buildZoneList(List<Map<String, dynamic>> zones) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: zones.length,
      itemBuilder: (_, i) {
        final zone = zones[i];
        final occupied = zone['occupiedBins'] as int;
        final total = zone['binCount'] as int;
        final pct = total == 0 ? 0.0 : occupied / total;

        return GestureDetector(
          onTap: () => setState(() => _selectedZone = zone['code'] as String),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
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
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _zoneColor(
                          zone['code'] as String,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          zone['code'] as String,
                          style: TextStyle(
                            color: _zoneColor(zone['code'] as String),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            zone['name'] as String,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$occupied / $total bins occupied',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 4,
                    backgroundColor: AppTheme.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _zoneColor(zone['code'] as String),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBinList() {
    final bins = _zoneBins;
    final zoneName =
        WarehouseMockData.zones.firstWhere(
              (z) => z['code'] == _selectedZone,
            )['name']
            as String;

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Text(
                zoneName,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${bins.length} bin${bins.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppTheme.divider),
        Expanded(
          child: bins.isEmpty
              ? const Center(
                  child: Text(
                    'No bins in this zone',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bins.length,
                  itemBuilder: (_, i) {
                    final bin = bins[i];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BinContentsScreen(bin: bin),
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.shelves,
                                color: AppTheme.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bin.binCode,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${bin.aisle} · Rack ${bin.rack} · ${bin.level}',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  if (bin.contents.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      '${bin.contents.length} item${bin.contents.length == 1 ? '' : 's'}',
                                      style: const TextStyle(
                                        color: AppTheme.success,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ] else ...[
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Empty',
                                      style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: AppTheme.textSecondary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Color _zoneColor(String code) => switch (code) {
    'A' => AppTheme.primary,
    'B' => AppTheme.warning,
    'C' => AppTheme.success,
    _ => AppTheme.textSecondary,
  };
}
