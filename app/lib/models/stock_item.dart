class BinStock {
  final String binCode;
  final String zone;
  final double qty;
  final String unit;
  final String? batchNumber;

  const BinStock({
    required this.binCode,
    required this.zone,
    required this.qty,
    required this.unit,
    this.batchNumber,
  });
}

class StockItem {
  final String itemCode;
  final String description;
  final String category;
  final String unit;
  final List<BinStock> binStocks;

  const StockItem({
    required this.itemCode,
    required this.description,
    required this.category,
    required this.unit,
    required this.binStocks,
  });

  double get totalQty => binStocks.fold(0, (s, b) => s + b.qty);
}
