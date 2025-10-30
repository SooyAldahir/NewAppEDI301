import 'dart:convert';
import '../core/api_client_http.dart';

class EventosApi {
  final ApiHttp _http = ApiHttp();

  Future<int> crearEvento({
    required int idUsuario,
    String? detalles,
    required DateTime fecha,
  }) async {
    final res = await _http.postJson(
      '/api/eventos',
      data: {
        "IdUsuario": idUsuario,
        "Detalles": detalles,
        "Fecha": fecha.toUtc().toIso8601String(),
      },
    );

    if (res.statusCode >= 400) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }

    final body = jsonDecode(res.body);
    if (body is Map<String, dynamic>) {
      // Ajusta la clave según tu backend
      if (body.containsKey('EventoID')) {
        return (body['EventoID'] as num).toInt();
      }
      if (body.containsKey('id')) {
        return (body['id'] as num).toInt();
      }
    }
    throw Exception('La API no retornó un id de evento válido');
  }

  Future<List<Map<String, dynamic>>> listar() async {
    final res = await _http.getJson('/api/eventos');

    if (res.statusCode >= 400) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body);

    if (data is List) {
      return data
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }

    // Por si tu backend envía { "data": [ ... ] } o similar
    if (data is Map && data.values.isNotEmpty && data.values.first is List) {
      final list = data.values.first as List;
      return list
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }

    return <Map<String, dynamic>>[];
  }
}
