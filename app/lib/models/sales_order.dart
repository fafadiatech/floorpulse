enum SOStatus {
  draft,
  confirmed,
  inProduction,
  dispatched,
  delivered,
  cancelled,
}

class SOLine {
  final String lineNo;
  final String itemCode;
  final String description;
  final double qty;
  final String unit;
  final double rate;
  final double discount; // percentage
  final String
  fulfillmentStatus; // 'Pending', 'In Production', 'Ready', 'Dispatched'

  const SOLine({
    required this.lineNo,
    required this.itemCode,
    required this.description,
    required this.qty,
    required this.unit,
    required this.rate,
    this.discount = 0,
    required this.fulfillmentStatus,
  });

  double get amount => qty * rate * (1 - discount / 100);
}

class SalesPaymentEntry {
  final String date;
  final String mode; // 'NEFT', 'Cheque', 'Cash', 'UPI'
  final String reference;
  final double amount;
  final String status; // 'Cleared', 'Pending', 'Bounced'

  const SalesPaymentEntry({
    required this.date,
    required this.mode,
    required this.reference,
    required this.amount,
    required this.status,
  });
}

class SalesOrder {
  final String id;
  final String soNumber;
  final String customerId;
  final String customerName;
  final DateTime orderDate;
  final DateTime expectedDelivery;
  final SOStatus status;
  final List<SOLine> lines;
  final double totalAmount;
  final double paidAmount;
  final String paymentTerms;
  final String deliveryAddress;
  final List<SalesPaymentEntry> payments;
  final String? workOrderRef;

  const SalesOrder({
    required this.id,
    required this.soNumber,
    required this.customerId,
    required this.customerName,
    required this.orderDate,
    required this.expectedDelivery,
    required this.status,
    required this.lines,
    required this.totalAmount,
    this.paidAmount = 0,
    required this.paymentTerms,
    required this.deliveryAddress,
    this.payments = const [],
    this.workOrderRef,
  });

  double get balance => totalAmount - paidAmount;
}
