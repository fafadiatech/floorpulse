enum InspectionType { incoming, inProcess, finalInspection }

enum InspectionStatus { pending, inProgress, completed, overdue }

class InspectionItem {
  final String id;
  final String referenceNumber;
  final String productName;
  final InspectionType type;
  final InspectionStatus status;
  final DateTime dueDate;
  final String assignedTo;
  final int quantity;
  final String? supplier;
  final String? workCenter;

  const InspectionItem({
    required this.id,
    required this.referenceNumber,
    required this.productName,
    required this.type,
    required this.status,
    required this.dueDate,
    required this.assignedTo,
    required this.quantity,
    this.supplier,
    this.workCenter,
  });

  bool get isOverdue => status == InspectionStatus.overdue;
}
