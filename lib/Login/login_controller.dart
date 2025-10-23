import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart'; // tu ApiClient con Dio

class LoginController {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final loading = ValueNotifier<bool>(false);

  late BuildContext _ctx;

  void init(BuildContext context) => _ctx = context;

  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    loading.dispose();
  }

  void goToRegisterPage() {
    Navigator.pushNamed(_ctx, 'register');
  }

  Future<void> goToHomePage() async {
    // login_controller.dart (lo importante)
    final dio = ApiClient().dio;

    loading.value = true;
    try {
      final res = await dio.post(
        '/api/auth/login',
        data: {
          'login': emailCtrl.text.trim(), // correo / matrícula / num_empleado
          'password': passCtrl.text,
        },
      );

      final data = Map<String, dynamic>.from(res.data ?? {});
      final token = (data['session_token'] ?? '').toString();
      if (token.isEmpty) {
        throw Exception('No se recibió session_token');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_token', token);
      await prefs.setString('user', jsonEncode(data));

      FocusScope.of(_ctx).unfocus();
      Navigator.of(
        _ctx,
      ).pushNamedAndRemoveUntil('home', (_) => false); // ← SIEMPRE HOME
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      loading.value = false;
    }
  }

  // Mapa de roles -> ruta
  String _routeForRole(String rol, String tipoUsuario) {
    switch (rol) {
      case 'Admin':
        return 'admin';
      case 'PapaEDI':
      case 'MamaEDI':
        return 'home'; // tu home para padres
      case 'HijoEDI':
      case 'HijoSanguineo':
        return 'home'; // si luego quieres otra pantalla, crea 'home_child'
      default:
        // EXTERNO se trata como padre, aunque venga con rol distinto
        if (tipoUsuario == 'EXTERNO') return 'home';
        // fallback
        return 'home';
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(_ctx).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }
}
