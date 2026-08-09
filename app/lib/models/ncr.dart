import 'capa.dart';

enum NCRSeverity { minor, major, critical }

enum NCRStatus { open, underReview, capaRaised, closed }

class NCR {
  final String ncrNumber;
  final String productName;
  final String referenceNumber;
  final String defectType;
  final int quantityRejected;
  final NCRSeverity severity;
  NCRStatus status;
  final DateTime raisedDate;
  final String raisedBy;
  String? disposition;
  CAPA? capa;

  NCR({
    required this.ncrNumber,
    required this.productName,
    required this.referenceNumber,
    required this.defectType,
    required this.quantityRejected,
    required this.severity,
    required this.status,
    required this.raisedDate,
    required this.raisedBy,
    this.disposition,
    this.capa,
  });
}
