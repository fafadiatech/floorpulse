enum WorkOrderStatus { pending, inProgress, completed, onHold }

enum Priority { low, medium, high, critical }

class WorkOrder {
  final String id;
  final String woNumber;
  final String productName;
  final int quantity;
  final int completedQty;
  final DateTime dueDate;
  final WorkOrderStatus status;
  final Priority priority;
  final String assignedTeam;
  final String description;

  const WorkOrder({
    required this.id,
    required this.woNumber,
    required this.productName,
    required this.quantity,
    required this.completedQty,
    required this.dueDate,
    required this.status,
    required this.priority,
    required this.assignedTeam,
    required this.description,
  });

  double get progress => quantity > 0 ? completedQty / quantity : 0.0;

  bool get isOverdue =>
      dueDate.isBefore(DateTime.now()) && status != WorkOrderStatus.completed;
}
