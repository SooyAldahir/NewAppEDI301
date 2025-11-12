// lib/services/familia_api.dart
import 'dart:convert';
import 'dart:io';
import 'package:edi301/core/api_client_http.dart';
import 'package:edi301/models/family_model.dart';
import 'package:http/http.dart' as http;

class FamiliaApi {
  final ApiHttp _http = ApiHttp();
  // Ya no necesita TokenStorage

  Future<Family> uploadFamilyFotos({
    required int familiaId,
    File? fotoPortada,
    File? fotoPerfil,
  }) async {
    // El token se añade automáticamente por el 'send' de ApiHttp

    final files = <http.MultipartFile>[];
    if (fotoPortada != null) {
      files.add(
        await http.MultipartFile.fromPath('foto_portada', fotoPortada.path),
      );
    }
    if (fotoPerfil != null) {
      files.add(
        await http.MultipartFile.fromPath('foto_perfil', fotoPerfil.path),
      );
    }

    final streamedResponse = await _http.patchMultipart(
      '/api/familias/$familiaId/fotos',
      files: files,
    );

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 400) {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }

    final updatedFamilyData = await getById(familiaId);
    if (updatedFamilyData == null) {
      throw Exception('No se pudo recargar la familia');
    }
    return Family.fromJson(updatedFamilyData);
  }

  Future<Family> createFamily({
    required String nombreFamilia,
    required String residencia,
    String? direccion,
    int? papaId,
    int? mamaId,
    List<int>? hijos,
  }) async {
    // Se elimina el parámetro 'token:'
    final res = await _http.postJson(
      '/api/familias',
      data: {
        'nombre_familia': nombreFamilia,
        'residencia': residencia,
        'direccion': direccion,
        'papa_id': papaId,
        'mama_id': mamaId,
        'hijos': hijos ?? [],
      },
    );
    if (res.statusCode >= 400) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
    final data = jsonDecode(res.body);
    return Family.fromJson(data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>?> getById(int familyId) async {
    // Se elimina el parámetro 'token:'
    final res = await _http.getJson('/api/familias/$familyId');
    if (res.statusCode == 404) return null;
    if (res.statusCode >= 400) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<List<Family>> getMyFamily() async {
    // Se elimina el parámetro 'token:'
    final res = await _http.getJson('/api/familias/');
    if (res.statusCode >= 400) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
    final data = jsonDecode(res.body);
    if (data is List) {
      return data
          .map<Family>((e) => Family.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return <Family>[];
  }

  Future<List<Family>> searchByName(String name) async {
    // Se elimina el parámetro 'token:'
    final res = await _http.getJson('/api/familias/search?name=$name');
    if (res.statusCode >= 400) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
    final data = jsonDecode(res.body);
    if (data is List) {
      return data
          .map<Family>((e) => Family.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return <Family>[];
  }
}
