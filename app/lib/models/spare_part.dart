class SparePart {
  final String id;
  final String partNo;
  final String description;
  final String unit;
  final String location;
  final double qtyOnHand;
  final double reorderLevel;
  final bool isBelowReorder;

  const SparePart({
    required this.id,
    required this.partNo,
    required this.description,
    required this.unit,
    required this.location,
    required this.qtyOnHand,
    required this.reorderLevel,
    required this.isBelowReorder,
  });
}
