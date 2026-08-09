enum WarehouseTaskType { grn, putAway, issue, pick, cycleCount }

enum WarehouseTaskStatus { pending, inProgress, completed, overdue }

class WarehouseTask {
  final String id;
  final WarehouseTaskType type;
  WarehouseTaskStatus status;
  final String referenceNumber;
  final String description;
  final String? detail;
  final DateTime dueDate;
  final int itemCount;

  WarehouseTask({
    required this.id,
    required this.type,
    required this.status,
    required this.referenceNumber,
    required this.description,
    this.detail,
    required this.dueDate,
    required this.itemCount,
  });

  bool get isOverdue =>
      status == WarehouseTaskStatus.overdue ||
      (status == WarehouseTaskStatus.pending &&
          dueDate.isBefore(DateTime.now()));
}
