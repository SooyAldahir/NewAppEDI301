// lib/services/users_api.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';
import '../models/user.dart';
import 'package:edi301/models/family_model.dart' as fm;

class UsersApi {
  final Dio _dio = ApiClient().dio;

  Future<void> deleteSoft(int id) async {
    await _dio.delete('/api/users/$id');
  }

  /// Familias por documento (matrícula o numEmpleado)
  Future<List<fm.Family>> familiasByDocumento({
    int? matricula,
    int? numEmpleado,
  }) async {
    final r = await _dio.get(
      '/api/users/familias/by-doc/search',
      queryParameters: {
        if (matricula != null) 'matricula': matricula,
        if (numEmpleado != null) 'numEmpleado': numEmpleado,
      },
    );

    final data = r.data;
    if (data is List) {
      return data
          .map((e) => fm.Family.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    if (data is Map && data.values.length == 1 && data.values.first is List) {
      return (data.values.first as List)
          .map((e) => fm.Family.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return <fm.Family>[];
  }

  Future<User> registerAlumno({
    required int matricula,
    required String nombre,
    required String apellido,
    required String email,
    required String contrasena,
    String? estado,
  }) async {
    final payload = {
      "TipoUsuario": "ALUMNO",
      "Matricula": matricula,
      "Nombre": nombre,
      "Apellido": apellido,
      "E_mail": email,
      "Contrasena": contrasena,
      "Estado": estado,
    };
    final r = await _dio.post('/api/users/register', data: payload);
    final id = r.data['IdUsuario'] as int;
    return getById(id);
  }

  Future<User> registerEmpleado({
    required int numEmpleado,
    required String nombre,
    required String apellido,
    required String email,
    required String contrasena,
    String? estado,
  }) async {
    final payload = {
      "TipoUsuario": "EMPLEADO",
      "NumEmpleado": numEmpleado,
      "Nombre": nombre,
      "Apellido": apellido,
      "E_mail": email,
      "Contrasena": contrasena,
      "Estado": estado,
    };
    final r = await _dio.post('/api/users/register', data: payload);
    final id = r.data['IdUsuario'] as int;
    return getById(id);
  }

  Future<User> login(String email, String password) async {
    final r = await _dio.post(
      '/api/users/login',
      data: {"E_mail": email, "Contrasena": password},
    );
    final user = User.fromJson(r.data);
    if (user.token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_token', user.token!);
    }
    return user;
  }

  Future<User> getById(int id) async {
    final r = await _dio.get('/api/users/$id');
    return User.fromJson(r.data);
  }

  Future<List<User>> search({String? q, String? tipo}) async {
    final r = await _dio.get(
      '/api/users',
      queryParameters: {
        if (q != null && q.isNotEmpty) 'q': q,
        if (tipo != null && tipo.isNotEmpty) 'tipo': tipo,
      },
    );
    return (r.data as List).map((e) => User.fromJson(e)).toList();
  }

  Future<User> update(
    int id, {
    String? nombre,
    String? apellido,
    String? estado,
    bool? esActivo,
    bool? esAdmin,
  }) async {
    final r = await _dio.patch(
      '/api/users/$id',
      data: {
        if (nombre != null) "Nombre": nombre,
        if (apellido != null) "Apellido": apellido,
        if (estado != null) "Estado": estado,
        if (esActivo != null) "es_Activo": esActivo,
        if (esAdmin != null) "es_Admin": esAdmin,
      },
    );
    return User.fromJson(r.data);
  }
}
