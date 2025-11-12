// lib/core/api_client_http.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiHttp extends http.BaseClient {
  ApiHttp._internal();

  static final ApiHttp _i = ApiHttp._internal();
  factory ApiHttp() => _i;

  // Ajusta tu base URL:
  static const String _baseUrl = 'http://10.219.84.3:3000';

  // --- 1. HACEMOS PÚBLICA LA BASE URL ---
  static String get baseUrl => _baseUrl;
  // ------------------------------------

  final http.Client _inner = http.Client();

  /// Tiempo máximo de espera por request
  final Duration _timeout = const Duration(seconds: 20);

  /// Si necesitas headers comunes en todas las llamadas, agrégalos aquí
  Map<String, String> get _baseHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<String?> _readToken() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString('session_token');
    return (t != null && t.isNotEmpty) ? t : null;
  }

  Uri _resolve(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Uri.parse(url);
    }
    final base = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    final path = url.startsWith('/') ? url : '/$url';
    return Uri.parse('$base$path');
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await _readToken();
    request.headers.addAll(_baseHeaders);
    if (token != null) {
      // --- 2. CORRECCIÓN DE AUTH (sin "Bearer ") ---
      request.headers['Authorization'] = token;
    }
    return _inner.send(request).timeout(_timeout);
  }

  /// Atajos tipo “Dio”: GET/POST/PUT/DELETE JSON

  Future<http.Response> getJson(String url, {Map<String, dynamic>? query}) {
    final uri = _resolve(url).replace(
      queryParameters: {...?query?.map((k, v) => MapEntry(k, v?.toString()))},
    );
    return get(uri).timeout(_timeout);
  }

  Future<http.Response> postJson(String url, {Object? data}) {
    final uri = _resolve(url);
    return post(
      uri,
      body: data == null ? null : jsonEncode(data),
    ).timeout(_timeout);
  }

  Future<http.Response> putJson(String url, {Object? data}) {
    final uri = _resolve(url);
    return put(
      uri,
      body: data == null ? null : jsonEncode(data),
    ).timeout(_timeout);
  }

  Future<http.Response> deleteJson(String url, {Object? data}) {
    final uri = _resolve(url);
    final hasBody = data != null;
    if (hasBody) {
      final req = http.Request('DELETE', uri);
      req.body = jsonEncode(data);
      return send(req).then(http.Response.fromStream);
    }
    return delete(uri).timeout(_timeout);
  }

  /// Subida multipart (POST)
  Future<http.StreamedResponse> multipart(
    String url, {
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
  }) {
    final uri = _resolve(url);
    final req = http.MultipartRequest('POST', uri);
    if (fields != null) req.fields.addAll(fields);
    if (files != null) req.files.addAll(files);
    return send(req);
  }

  // --- 3. AÑADIMOS 'patchMultipart' (para fotos de familia) ---
  Future<http.StreamedResponse> patchMultipart(
    String url, {
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
  }) {
    final uri = _resolve(url);
    final req = http.MultipartRequest('PATCH', uri);
    if (fields != null) req.fields.addAll(fields);
    if (files != null) req.files.addAll(files);
    return send(req);
  }
  // ------------------------------------

  // --- 4. AÑADIMOS 'patchJson' (arregla tu error actual) ---
  Future<http.Response> patchJson(String url, {Object? data}) {
    final uri = _resolve(url);
    final req = http.Request('PATCH', uri);
    if (data != null) req.body = jsonEncode(data);
    return send(req).then(http.Response.fromStream).timeout(_timeout);
  }

  // ----------------------------------------------------
}
