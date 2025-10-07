class Family {
  final String familyName;
  final String fatherName;
  final String motherName;
  final String residence;
  final List<String> children;

  Family({
    required this.familyName,
    required this.fatherName,
    required this.motherName,
    required this.residence,
    this.children = const [],
  });
}
