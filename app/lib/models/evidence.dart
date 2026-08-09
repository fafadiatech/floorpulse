class Evidence {
  final String id;
  final String type; // 'photo' | 'note'
  final String label;
  final String description;
  final DateTime timestamp;

  const Evidence({
    required this.id,
    required this.type,
    required this.label,
    required this.description,
    required this.timestamp,
  });
}
