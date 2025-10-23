import 'package:dio/dio.dart';
import '../core/api_client.dart';

class PublicacionesApi {
  final Dio _dio = ApiClient().dio;

  Future<int> crearPost(int idUsuario) async {
    final r = await _dio.post(
      '/api/publicaciones',
      data: {"IdUsuario": idUsuario},
    );
    return r.data['PostID'] as int;
  }

  Future<void> like(int postId) async {
    await _dio.post('/api/publicaciones/$postId/like');
  }
}
