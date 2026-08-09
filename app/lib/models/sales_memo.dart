enum MemoType { voice, note }

class SalesMemo {
  final String id;
  MemoType type;
  String content;
  final DateTime createdAt;
  String? customerId;
  String? customerName;
  String? productInterest;

  SalesMemo({
    required this.id,
    required this.type,
    required this.content,
    required this.createdAt,
    this.customerId,
    this.customerName,
    this.productInterest,
  });
}
