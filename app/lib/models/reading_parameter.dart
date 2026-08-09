enum ParameterType { measurement, checklist }

class ReadingParameter {
  final String id;
  final String name;
  final ParameterType type;
  final double? nominalValue;
  final double? tolerancePlus;
  final double? toleranceMinus;
  final String? unit;
  final String? checkDescription;

  const ReadingParameter({
    required this.id,
    required this.name,
    required this.type,
    this.nominalValue,
    this.tolerancePlus,
    this.toleranceMinus,
    this.unit,
    this.checkDescription,
  });
}
