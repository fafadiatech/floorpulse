enum CustomerStatus { active, inactive, onHold }

class Customer {
  final String id;
  final String name;
  final String code;
  final String contactPerson;
  final String phone;
  final String email;
  final String address;
  final String city;
  final String gstin;
  final String segment; // 'Dealer', 'Distributor', 'Direct'
  final double outstandingBalance;
  final double creditLimit;
  final String paymentTerms;
  final CustomerStatus status;
  final DateTime lastVisitDate;

  const Customer({
    required this.id,
    required this.name,
    required this.code,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.address,
    required this.city,
    required this.gstin,
    required this.segment,
    required this.outstandingBalance,
    required this.creditLimit,
    required this.paymentTerms,
    required this.status,
    required this.lastVisitDate,
  });

  double get creditUtilisation =>
      creditLimit == 0 ? 0 : outstandingBalance / creditLimit;
  bool get isOverLimit => outstandingBalance > creditLimit;
}

class LedgerEntry {
  final String date;
  final String type; // 'Invoice', 'Payment', 'Credit Note', 'Debit Note'
  final String reference;
  final double
  amount; // positive = debit (you owe), negative = credit (payment)
  final double balance;
  final String? invoiceId;

  const LedgerEntry({
    required this.date,
    required this.type,
    required this.reference,
    required this.amount,
    required this.balance,
    this.invoiceId,
  });
}
