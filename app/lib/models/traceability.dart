class TraceabilityNode {
  final String id;
  final String label;
  final String type; // 'batch' | 'material' | 'product' | 'supplier'
  final String detail;
  final List<TraceabilityNode> children;

  const TraceabilityNode({
    required this.id,
    required this.label,
    required this.type,
    required this.detail,
    this.children = const [],
  });
}

class StockLedgerEntry {
  final String date;
  final String movementType; // 'GRN' | 'Issue' | 'Transfer' | 'Adjustment'
  final double quantity;
  final String unit;
  final double balance;
  final String reference;

  const StockLedgerEntry({
    required this.date,
    required this.movementType,
    required this.quantity,
    required this.unit,
    required this.balance,
    required this.reference,
  });
}
