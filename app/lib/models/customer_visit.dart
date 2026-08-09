enum VisitStatus { scheduled, checkedIn, completed, missed }

class CustomerVisit {
  final String id;
  final String customerId;
  final String customerName;
  final String city;
  final DateTime scheduledAt;
  final String purpose;
  VisitStatus status;
  DateTime? checkInTime;
  DateTime? checkOutTime;
  String? notes;
  String?
  outcome; // 'Order Placed', 'Follow-up Required', 'No Interest', 'Demo Done'

  CustomerVisit({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.city,
    required this.scheduledAt,
    required this.purpose,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    this.notes,
    this.outcome,
  });
}
