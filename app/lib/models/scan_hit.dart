class ScanHit {
  final String type;
  final String doctype;
  final String name;
  final String label;
  final Map<String, dynamic> extra;

  const ScanHit({
    required this.type,
    required this.doctype,
    required this.name,
    required this.label,
    this.extra = const {},
  });

  factory ScanHit.fromJson(Map<String, dynamic> json) {
    final extra = json['extra'];
    return ScanHit(
      type: (json['type'] ?? '').toString(),
      doctype: (json['doctype'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      label: (json['label'] ?? json['name'] ?? '').toString(),
      extra: extra is Map<String, dynamic>
          ? extra
          : extra is Map
          ? Map<String, dynamic>.from(extra)
          : const {},
    );
  }
}
