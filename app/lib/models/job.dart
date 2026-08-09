enum JobStatus { notStarted, inProgress, completed, onHold }

class Job {
  final String id;
  final String jobNumber;
  final String title;
  final String workOrderId;
  final String workOrderNumber;
  JobStatus status;
  final DateTime dueDate;
  final String description;
  final String location;
  List<String> notes;

  Job({
    required this.id,
    required this.jobNumber,
    required this.title,
    required this.workOrderId,
    required this.workOrderNumber,
    required this.status,
    required this.dueDate,
    required this.description,
    required this.location,
    List<String>? notes,
  }) : notes = notes ?? [];

  bool get isOverdue =>
      dueDate.isBefore(DateTime.now()) && status != JobStatus.completed;
}
