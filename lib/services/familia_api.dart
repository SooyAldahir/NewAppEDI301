// lib/services/familia_api.dart
import 'package:dio/dio.dart';
import 'package:edi301/core/api_client.dart';
import 'package:edi301/models/family_model.dart';
import 'package:flutter/material.dart';

class FamiliaApi {
  final Dio _dio = ApiClient().dio;

  String _normalizeResidence(String r) {
    final s = r.trim().toUpperCase();
    if (s.startsWith('INT')) return 'INTERNA';
    if (s.startsWith('EXT')) return 'EXTERNA';
    return 'INTERNA';
  }

  Future<Family> createFamily({
    required String nombreFamilia,
    required String residencia,
    String? direccion,
  }) async {
    final payload = <String, dynamic>{
      'nombre_familia': nombreFamilia,
      'residencia': _normalizeResidence(residencia),
      if (direccion != null && direccion.trim().isNotEmpty)
        'direccion': direccion.trim(),
    };
    final r = await _dio.post(
      '/api/familias',
      data: payload,
      options: Options(validateStatus: (_) => true), // <- no lance en 400
    );
    debugPrint('POST /api/familias -> ${r.statusCode} :: ${r.data}');

    final data = r.data;
    final Map<String, dynamic> m = (data is Map && data['data'] is Map)
        ? Map<String, dynamic>.from(data['data'])
        : Map<String, dynamic>.from(data as Map);
    return Family.fromJson(m);
  }

  Future<List<Map<String, dynamic>>> buscarFamiliasPorNombre(String q) async {
    final r = await _dio.get(
      '/api/familias/search',
      queryParameters: {'name': q},
    );
    final data = r.data;
    if (data is List) return data.cast<Map<String, dynamic>>();
    return <Map<String, dynamic>>[];
  }

  Future<Map<String, dynamic>?> getById(int id) async {
    final r = await _dio.get('/api/familias/$id');
    final data = r.data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  Future<Map<String, dynamic>?> getByIdent(int ident) async {
    final r = await _dio.get('/api/familias/por-ident/$ident');
    final data = r.data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }
}
