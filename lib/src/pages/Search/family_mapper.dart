import 'package:edi301/models/family_model.dart';

class FamilyMapper {
  static Family fromBackend(Map<String, dynamic> j) {
    final name = (j['Nombre_Familia'] ?? '').toString();
    final residence = (j['Residencia'] ?? '').toString();

    // Campos que tu tarjeta muestra pero la API no trae; dejamos vacíos/placeholder.
    return Family(
      familyName: name,
      fatherName: (j['Padre'] ?? '').toString(), // si no existe, quedará vacío
      motherName: (j['Madre'] ?? '').toString(),
      residence: residence.isEmpty ? 'Desconocida' : residence,
      assignedStudents: const [],
      householdChildren: const [],
      fatherEmployeeId: null,
      motherEmployeeId: null,
    );
  }
}
