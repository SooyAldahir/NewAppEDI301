// lib/core/api_client.dart
import 'package:dio/dio.dart';

class ApiClient {
  static final ApiClient _i = ApiClient._();
  factory ApiClient() => _i;
  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://10.50.2.219:3000',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    // Interceptor de auth (token Bearer)
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await authStore.getToken(); // tu implementación
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (e, handler) async {
          // Opcional: si 401 -> redirigir a login / refrescar token
          // if (e.response?.statusCode == 401) { ... }
          return handler.next(e);
        },
      ),
    );

    // Opcional: logger
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: false),
    );
  }

  late final Dio _dio;
  Dio get dio => _dio;
}

// Simulación de donde guardas el token
class authStore {
  static Future<String?> getToken() async {
    // TODO: lee de SecureStorage/SharedPreferences/etc.
    return _cachedToken;
  }

  static String? _cachedToken; // setéalo al hacer login
}
