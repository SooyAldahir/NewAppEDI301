// lib/services/familia_api.dart
import 'dart:convert';
import 'dart:io'; // <-- Importar para File
import 'package:edi301/core/api_client_http.dart';
import 'package:edi301/models/family_model.dart';
import 'package:edi301/auth/token_storage.dart'; // <-- Importar para el token
import 'package:http/http.dart' as http; // <-- Importar http

class FamiliaApi {
  final ApiHttp _http = ApiHttp();

  // --- AÑADE ESTA FUNCIÓN ---
  Future<Family> uploadFamilyFotos({
    required int familiaId,
    required String token,
    File? fotoPortada,
    File? fotoPerfil,
  }) async {
    // 1. Crear la petición multipart
    final uri = ApiHttp.getUri('/api/familias/$familiaId/fotos');
    final request = http.MultipartRequest('PATCH', uri);

    // 2. Añadir cabeceras
    request.headers['Authorization'] = token;

    // 3. Añadir archivo de portada (si existe)
    if (fotoPortada != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'foto_portada', // Este es el 'name' que espera el backend
          fotoPortada.path,
        ),
      );
    }

    // 4. Añadir archivo de perfil (si existe)
    if (fotoPerfil != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'foto_perfil', // Este es el 'name' que espera el backend
          fotoPerfil.path,
        ),
      );
    }

    // 5. Enviar la petición
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 400) {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }

    // 6. Devolver la familia actualizada
    final data = jsonDecode(response.body);
    // Asumimos que la API /getById devuelve el modelo 'Family' completo
    final updatedFamilyData = await getById(familiaId);
    return Family.fromJson(updatedFamilyData!);
  }
  // --- FIN DE LA NUEVA FUNCIÓN ---

  // ... (tus funciones createFamily, getById, getMyFamily, searchByName) ...
  // (Las he copiado de tu proyecto para que no falten)

  Future<Family> createFamily({
    required String nombreFamilia,
    required String residencia,
    String? direccion,
    int? papaId,
    int? mamaId,
    List<int>? hijos,
  }) async {
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
    final res = await _http.getJson('/api/familias/$familyId');
    if (res.statusCode == 404) return null;
    if (res.statusCode >= 400) {
      throw Exception('Error ${res.statusCode}: ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<List<Family>> getMyFamily() async {
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
