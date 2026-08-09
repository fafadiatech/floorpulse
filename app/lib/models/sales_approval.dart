enum ApprovalType {
  discountOverride,
  creditLimitOverride,
  specialTerm,
  returnApproval,
}

enum ApprovalStatus { pending, approved, rejected }

class SalesApproval {
  final String id;
  final ApprovalType type;
  final String title;
  final String customerId;
  final String customerName;
  final String? soNumber;
  final String requestedBy;
  final DateTime requestedAt;
  final double requestedValue;
  final double? approvedValue;
  final String details;
  ApprovalStatus status;
  String? remarks;

  SalesApproval({
    required this.id,
    required this.type,
    required this.title,
    required this.customerId,
    required this.customerName,
    this.soNumber,
    required this.requestedBy,
    required this.requestedAt,
    required this.requestedValue,
    this.approvedValue,
    required this.details,
    required this.status,
    this.remarks,
  });
}
