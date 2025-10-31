import 'dart:convert';
import 'package:edi301/core/api_client_http.dart';

class MembersApi {
  final ApiHttp _http = ApiHttp();

  Future<void> addMember({
    required int idFamilia,
    required int idUsuario,
    required String tipoMiembro,
  }) async {
    // Normaliza SIEMPRE lo que se manda al backend
    final type = tipoMiembro
        .trim()
        .toUpperCase(); // <- elimina espacios y pone MAYÚSCULAS

    // Sanity-check local (evita pegarle al back con algo inválido)
    const allowed = {'PADRE', 'MADRE', 'HIJO'};
    if (!allowed.contains(type)) {
      throw Exception(
        'tipo_miembro inválido: "$tipoMiembro" (usa PADRE|MADRE|HIJO)',
      );
    }

    final payload = {
      'id_familia': idFamilia, // int
      'id_usuario': idUsuario, // int
      'tipo_miembro': type, // PADRE|MADRE|HIJO
    };

    // Log útil para depurar (puedes quitarlo luego)
    // print('POST /api/miembros payload => ${jsonEncode(payload)}');

    final res = await _http.postJson('/api/miembros', data: payload);

    if (res.statusCode >= 400) {
      // intenta sacar mensaje legible si el back manda { error: "..."}
      String msg = 'Error ${res.statusCode}: ${res.body}';
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map && decoded['error'] is String) {
          msg = decoded['error'] as String;
        } else if (decoded is Map && decoded['message'] is String) {
          msg = decoded['message'] as String;
        }
      } catch (_) {}
      throw Exception(msg);
    }
  }

  Future<Map<String, dynamic>> addAlumnsToFamily(
    int familyId,
    List<String> matriculas,
  ) async {
    final res = await _http.postJson(
      '/api/miembros/familia/$familyId/alumnos',
      data: {'matriculas': matriculas},
    );

    if (res.statusCode >= 400) {
      throw Exception('Error al agregar alumnos: ${res.body}');
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
