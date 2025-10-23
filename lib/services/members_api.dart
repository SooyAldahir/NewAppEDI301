// lib/services/members_api.dart
import 'package:dio/dio.dart';
import 'package:edi301/core/api_client.dart';
import 'package:flutter/material.dart';

// services/members_api.dart
class MembersApi {
  final Dio _dio = ApiClient().dio;

  Future<void> addMember({
    required int idFamilia,
    required int idUsuario,
    required String tipoMiembro,
  }) async {
    final r = await _dio.post(
      '/api/miembros', // <-- exacto a lo montado arriba
      data: {
        'id_familia': idFamilia,
        'id_usuario': idUsuario,
        'tipo_miembro': tipoMiembro,
      },
      options: Options(validateStatus: (_) => true),
    );
    debugPrint('POST ${r.requestOptions.uri} -> ${r.statusCode} :: ${r.data}');
    if ((r.statusCode ?? 500) >= 400) {
      throw Exception(
        r.data is Map
            ? (r.data['error'] ?? 'No se pudo agregar miembro')
            : 'No se pudo agregar miembro',
      );
    }
  }
}
