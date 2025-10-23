import 'package:dio/dio.dart';
import '../core/api_client.dart';

class EventosApi {
  final Dio _dio = ApiClient().dio;

  Future<int> crearEvento({
    required int idUsuario,
    String? detalles,
    required DateTime fecha,
  }) async {
    final r = await _dio.post(
      '/api/eventos',
      data: {
        "IdUsuario": idUsuario,
        "Detalles": detalles,
        "Fecha": fecha.toUtc().toIso8601String(),
      },
    );
    return r.data['EventoID'] as int;
  }

  Future<List<Map<String, dynamic>>> listar() async {
    final r = await _dio.get('/api/eventos');
    return (r.data as List).cast<Map<String, dynamic>>();
  }
}
