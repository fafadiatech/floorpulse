enum POStatus { pending, partialGRN, received, closed }

class POLine {
  final String lineNo;
  final String itemCode;
  final String description;
  final double orderedQty;
  final String unit;
  double receivedQty;

  POLine({
    required this.lineNo,
    required this.itemCode,
    required this.description,
    required this.orderedQty,
    required this.unit,
    this.receivedQty = 0,
  });

  bool get isFullyReceived => receivedQty >= orderedQty;
  bool get isPartial => receivedQty > 0 && receivedQty < orderedQty;
  bool get isExcess => receivedQty > orderedQty;
}

class PurchaseOrder {
  final String poNumber;
  final String supplier;
  final DateTime expectedDate;
  POStatus status;
  final List<POLine> lines;
  final String buyerContact;

  PurchaseOrder({
    required this.poNumber,
    required this.supplier,
    required this.expectedDate,
    required this.status,
    required this.lines,
    required this.buyerContact,
  });
}
