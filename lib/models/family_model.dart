// lib/models/family_model.dart
class Family {
  // PK unificada
  final int? id; // mapea id_familia / FamiliaID / id

  // Campos principales
  final String familyName;
  final String? fatherName;
  final String? motherName;
  final String? residencia; // 'INTERNA' | 'EXTERNA'
  final String? direccion;

  // ------- Compatibilidad con versiones anteriores de tu UI -------
  // Listas usadas sólo por UI local (no vienen de la BD)
  final List<String> assignedStudents; // "Alumnos asignados" (fake/local)
  final List<String> householdChildren; // "Hijos en casa"   (fake/local)

  // IDs de empleados (si algún día los quieres poblar)
  final int? fatherEmployeeId;
  final int? motherEmployeeId;

  // Getter legacy para no romper referencias: f.residence -> f.residencia
  String get residence => residencia ?? '';

  const Family({
    required this.id,
    required this.familyName,
    this.fatherName,
    this.motherName,
    this.residencia,
    this.direccion,
    this.assignedStudents = const [],
    this.householdChildren = const [],
    this.fatherEmployeeId,
    this.motherEmployeeId,
  });

  factory Family.fromJson(Map<String, dynamic> j) {
    // normaliza residencia a 'Interna' / 'Externa' si es posible
    String? _normalizeRes(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      final up = s.toUpperCase();
      if (up.startsWith('INT')) return 'Interna';
      if (up.startsWith('EXT')) return 'Externa';
      return s; // deja tal cual si viene otro valor
    }

    return Family(
      id: (j['id_familia'] ?? j['FamiliaID'] ?? j['id']) as int?,
      familyName:
          (j['nombre_familia'] ?? j['Nombre_Familia'] ?? j['nombre'] ?? '')
              .toString(),

      // 👇 ahora tomamos los nombres del JOIN si existen
      fatherName:
          (j['papa_nombre'] ??
                  j['Padre'] ??
                  j['padre'] ??
                  j['fatherName'] ??
                  j['nombre_padre'])
              ?.toString(),
      motherName:
          (j['mama_nombre'] ??
                  j['Madre'] ??
                  j['madre'] ??
                  j['motherName'] ??
                  j['nombre_madre'])
              ?.toString(),

      // residencia y dirección
      residencia: _normalizeRes(j['residencia'] ?? j['Residencia']),
      direccion: (j['direccion'] ?? j['Direccion'])?.toString(),

      // listas locales (UI)
      assignedStudents: const [],
      householdChildren: const [],

      // ids de empleados (por compatibilidad con distintas claves)
      fatherEmployeeId:
          (j['papa_id'] ??
                  j['Papa_id'] ??
                  j['PapaId'] ??
                  j['father_employee_id'])
              as int?,
      motherEmployeeId:
          (j['mama_id'] ??
                  j['Mama_id'] ??
                  j['MamaId'] ??
                  j['mother_employee_id'])
              as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id_familia': id,
    'nombre_familia': familyName,
    'padre': fatherName,
    'madre': motherName,
    'residencia': residencia,
    'direccion': direccion,
    'papa_id': fatherEmployeeId,
    'mama_id': motherEmployeeId,
  };

  Family copyWith({
    int? id,
    String? familyName,
    String? fatherName,
    String? motherName,
    String? residencia,
    String? direccion,
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
      residencia: residencia ?? this.residencia,
      direccion: direccion ?? this.direccion,
      assignedStudents: assignedStudents ?? this.assignedStudents,
      householdChildren: householdChildren ?? this.householdChildren,
      fatherEmployeeId: fatherEmployeeId ?? this.fatherEmployeeId,
      motherEmployeeId: motherEmployeeId ?? this.motherEmployeeId,
    );
  }
}
