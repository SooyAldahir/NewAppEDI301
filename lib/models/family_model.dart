// lib/models/family_model.dart
class Family {
  final int? id; // id en BD
  final String familyName; // "Familia Pérez López"
  final String fatherName; // nombre del padre (si lo tienes)
  final String motherName; // nombre de la madre (si lo tienes)
  final String residence; // 'Interna' | 'Externa' | 'Desconocida'
  final String? address; // solo si es Externa

  // Solo para UI (no vienen del backend)
  final List<String> assignedStudents; // alumnos asignados
  final List<String> householdChildren; // hijos en casa

  final int? fatherEmployeeId; // num. empleado padre (si aplica)
  final int? motherEmployeeId; // num. empleado madre (si aplica)

  const Family({
    this.id,
    required this.familyName,
    this.fatherName = '',
    this.motherName = '',
    this.residence = 'Desconocida',
    this.address,
    this.assignedStudents = const [],
    this.householdChildren = const [],
    this.fatherEmployeeId,
    this.motherEmployeeId,
  });

  Family copyWith({
    int? id,
    String? familyName,
    String? fatherName,
    String? motherName,
    String? residence,
    String? address,
    String? bio,
    List<String>? assignedStudents,
    List<String>? householdChildren,
    int? fatherEmployeeId,
    int? motherEmployeeId,
  }) {
    return Family(
      id: id ?? this.id,
      familyName: familyName ?? this.familyName,
      fatherName: fatherName ?? this.fatherName,
      motherName: motherName ?? this.motherName,
      residence: residence ?? this.residence,
      address: address ?? this.address,
      assignedStudents: assignedStudents ?? this.assignedStudents,
      householdChildren: householdChildren ?? this.householdChildren,
      fatherEmployeeId: fatherEmployeeId ?? this.fatherEmployeeId,
      motherEmployeeId: motherEmployeeId ?? this.motherEmployeeId,
    );
  }

  factory Family.fromJson(Map<String, dynamic> j) {
    return Family(
      id: j['FamiliaID'] ?? j['id_familia'] ?? j['id'],
      familyName:
          (j['Nombre_Familia'] ?? j['nombre_familia'] ?? j['nombre'] ?? '')
              .toString(),
      residence: (j['Residencia'] ?? j['residencia'] ?? 'Desconocida')
          .toString(),
      address: (j['Direccion'] ?? j['direccion'])?.toString(),
      fatherName: (j['Padre'] ?? j['padre'] ?? '').toString(),
      motherName: (j['Madre'] ?? j['madre'] ?? '').toString(),
      fatherEmployeeId: _toInt(
        j['NumEmpleadoPadre'] ?? j['padre_num_empleado'],
      ),
      motherEmployeeId: _toInt(
        j['NumEmpleadoMadre'] ?? j['madre_num_empleado'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'FamiliaID': id,
    'Nombre_Familia': familyName,
    'Residencia': residence,
    if (address != null && address!.trim().isNotEmpty) 'Direccion': address,
    if (fatherName.isNotEmpty) 'Padre': fatherName,
    if (motherName.isNotEmpty) 'Madre': motherName,
    if (fatherEmployeeId != null) 'NumEmpleadoPadre': fatherEmployeeId,
    if (motherEmployeeId != null) 'NumEmpleadoMadre': motherEmployeeId,
  };
}

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  final s = v.toString();
  return int.tryParse(s);
}
