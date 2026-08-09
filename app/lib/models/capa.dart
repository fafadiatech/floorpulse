enum CAPAStatus { open, inProgress, closed, overdue }

class CAPA {
  final String capaNumber;
  final String rootCause;
  final String correctiveAction;
  final String preventiveAction;
  final String owner;
  final DateTime dueDate;
  CAPAStatus status;

  CAPA({
    required this.capaNumber,
    required this.rootCause,
    required this.correctiveAction,
    required this.preventiveAction,
    required this.owner,
    required this.dueDate,
    required this.status,
  });
}
