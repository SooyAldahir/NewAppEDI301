import 'package:dio/dio.dart';
import '../core/api_client.dart';

class UserMini {
  final int id;
  final String nombre;
  final String apellido;
  final String tipo; // 'ALUMNO' | 'EMPLEADO'
  final int? matricula;
  final int? numEmpleado;
  final String? email;

  UserMini({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.tipo,
    this.matricula,
    this.numEmpleado,
    this.email,
  });

  factory UserMini.fromJson(Map<String, dynamic> j) => UserMini(
    id: (j['IdUsuario'] ?? j['id'] ?? j['id_usuario'] ?? 0) as int,
    nombre: (j['Nombre'] ?? j['nombre'] ?? '') as String,
    apellido: (j['Apellido'] ?? j['apellido'] ?? '') as String,
    tipo: (j['TipoUsuario'] ?? j['tipo_usuario'] ?? '') as String,
    matricula: _toIntOrNull(j['Matricula'] ?? j['matricula']),
    numEmpleado: _toIntOrNull(j['NumEmpleado'] ?? j['num_empleado']),
    email: (j['E_mail'] ?? j['correo'])?.toString(),
  );
}

class FamilyMini {
  final int id;
  final String nombre;
  final String? residencia;
  final String? biografia;

  FamilyMini({
    required this.id,
    required this.nombre,
    this.residencia,
    this.biografia,
  });

  factory FamilyMini.fromJson(Map<String, dynamic> j) => FamilyMini(
    id: (j['FamiliaID'] ?? j['id_familia'] ?? j['id'] ?? 0) as int,
    nombre:
        (j['Nombre_Familia'] ?? j['nombre_familia'] ?? j['nombre'] ?? '')
            as String,
    residencia: (j['Residencia'] ?? j['residencia'])?.toString(),
    biografia: (j['Biografia'] ?? j['biografia'])?.toString(),
  );
}

class SearchResult {
  final List<UserMini> alumnos;
  final List<UserMini> empleados;
  final List<FamilyMini> familias;
  final List<UserMini> externos;

  SearchResult({
    required this.alumnos,
    required this.empleados,
    required this.familias,
    required this.externos,
  });
  factory SearchResult.fromJson(Map<String, dynamic> j) => SearchResult(
    alumnos: _parseUsers(j['alumnos']),
    empleados: _parseUsers(j['empleados']),
    familias: _parseFamilies(j['familias']),
    externos: _parseUsers(j['externos']), // 👈 si no viene, deja []
  );
}

List<UserMini> _parseUsers(dynamic v) {
  if (v is List) {
    return v
        .map((e) => UserMini.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
  return const [];
}

List<FamilyMini> _parseFamilies(dynamic v) {
  if (v is List) {
    return v
        .map((e) => FamilyMini.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
  return const [];
}

class SearchApi {
  final Dio _dio = ApiClient().dio;

  // Devuelve Response con data=[] si la petición falla
  Future<Response> _safeGet(String path, {Map<String, dynamic>? query}) async {
    try {
      return await _dio.get(path, queryParameters: query);
    } on DioException catch (e) {
      // Opcional: log para depurar
      // print('GET $path ❌ ${e.response?.statusCode} ${e.response?.data}');
      return Response(
        requestOptions: RequestOptions(path: path),
        data: const [],
      );
    } catch (_) {
      return Response(
        requestOptions: RequestOptions(path: path),
        data: const [],
      );
    }
  }

  Future<SearchResult> searchAll(String input) async {
    final q = input.trim();
    if (q.isEmpty) {
      return SearchResult(
        alumnos: [],
        empleados: [],
        familias: [],
        externos: [],
      );
    }

    final isNumeric = RegExp(r'^\d+$').hasMatch(q);

    // Peticiones en paralelo
    final alumnosF = _safeGet(
      '/api/usuarios',
      query: {'tipo': 'ALUMNO', 'q': q},
    );
    final empleadosF = _safeGet(
      '/api/usuarios',
      query: {'tipo': 'EMPLEADO', 'q': q},
    );
    final externosF = _safeGet(
      '/api/usuarios',
      query: {'tipo': 'EXTERNO', 'q': q},
    ); // 👈 NUEVO

    final familiasByMatF = isNumeric
        ? _safeGet(
            '/api/usuarios/familias/by-doc/search',
            query: {'matricula': q},
          )
        : Future.value(
            Response(
              requestOptions: RequestOptions(path: ''),
              data: const [],
            ),
          );
    final familiasByEmpF = isNumeric
        ? _safeGet(
            '/api/usuarios/familias/by-doc/search',
            query: {'numEmpleado': q},
          )
        : Future.value(
            Response(
              requestOptions: RequestOptions(path: ''),
              data: const [],
            ),
          );
    final familiasByNameF = !isNumeric
        ? _safeGet('/api/familias/search', query: {'name': q})
        : Future.value(
            Response(
              requestOptions: RequestOptions(path: ''),
              data: const [],
            ),
          );

    final resps = await Future.wait<Response>([
      alumnosF, // 0
      empleadosF, // 1
      familiasByMatF, // 2
      familiasByEmpF, // 3
      familiasByNameF, // 4
      externosF, // 5 👈
    ]);

    List<dynamic> _ensureList(dynamic d) {
      if (d == null) return const [];
      if (d is List) return d;
      if (d is Map && d.containsKey('data') && d['data'] is List)
        return d['data'] as List;
      if (d is Map && d.containsKey('rows') && d['rows'] is List)
        return d['rows'] as List;
      if (d is Map && d.values.length == 1 && d.values.first is List)
        return List.from(d.values.first as List);
      return const [];
    }

    final alumnos = _ensureList(resps[0].data)
        .map((e) => UserMini.fromJson(Map<String, dynamic>.from(e)))
        .where((u) => u.tipo.toUpperCase() == 'ALUMNO')
        .toList();

    final empleados = _ensureList(resps[1].data)
        .map((e) => UserMini.fromJson(Map<String, dynamic>.from(e)))
        .where((u) => u.tipo.toUpperCase() == 'EMPLEADO')
        .toList();

    // 👇 externos reales desde el backend
    final externos = _ensureList(resps[5].data)
        .map((e) => UserMini.fromJson(Map<String, dynamic>.from(e)))
        .where((u) => u.tipo.toUpperCase() == 'EXTERNO')
        .toList();

    // Familias
    List<FamilyMini> familias;
    if (isNumeric) {
      final a = _ensureList(
        resps[2].data,
      ).map((e) => FamilyMini.fromJson(Map<String, dynamic>.from(e))).toList();
      final b = _ensureList(
        resps[3].data,
      ).map((e) => FamilyMini.fromJson(Map<String, dynamic>.from(e))).toList();
      final map = <int, FamilyMini>{};
      for (final f in [...a, ...b]) map[f.id] = f;
      familias = map.values.toList();
    } else {
      familias = _ensureList(
        resps[4].data,
      ).map((e) => FamilyMini.fromJson(Map<String, dynamic>.from(e))).toList();
    }

    return SearchResult(
      alumnos: alumnos,
      empleados: empleados,
      familias: familias,
      externos: externos, // 👈 ya no va vacío
    );
  }
}

/// util pequeño para campos numéricos que pueden venir como String/int/null
int? _toIntOrNull(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  final s = v.toString().trim();
  if (s.isEmpty) return null;
  final n = int.tryParse(s);
  return n;
}
