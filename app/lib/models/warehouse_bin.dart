class WarehouseBin {
  final String binCode;
  final String zone;
  final String aisle;
  final String rack;
  final String level;
  final String category; // 'Raw Material' | 'WIP' | 'Finished Goods'
  final List<BinContent> contents;

  const WarehouseBin({
    required this.binCode,
    required this.zone,
    required this.aisle,
    required this.rack,
    required this.level,
    required this.category,
    this.contents = const [],
  });

  bool get isEmpty => contents.isEmpty;
  double get utilizationPct =>
      contents.isEmpty ? 0 : (contents.length / 5.0).clamp(0, 1);
}

class BinContent {
  final String itemCode;
  final String description;
  final double qty;
  final String unit;
  final String? batchNumber;

  const BinContent({
    required this.itemCode,
    required this.description,
    required this.qty,
    required this.unit,
    this.batchNumber,
  });
}
