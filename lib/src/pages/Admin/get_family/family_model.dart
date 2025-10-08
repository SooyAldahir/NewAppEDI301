// lib/src/pages/Admin/get_family/family_model.dart
class Family {
  final String familyName;
  final String fatherName;
  final String motherName;
  final String residence; // 'Interna' | 'Externa'

  // Listas NO nulas
  final List<String> householdChildren; // Hijos en casa
  final List<String> assignedStudents; // Alumnos asignados

  Family({
    required this.familyName,
    required this.fatherName,
    required this.motherName,
    required this.residence,
    List<String>? householdChildren,
    List<String>? assignedStudents,
  }) : householdChildren = householdChildren ?? <String>[],
       assignedStudents = assignedStudents ?? <String>[];
}
