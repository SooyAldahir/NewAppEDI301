import 'package:flutter/material.dart';
import 'package:edi301/Login/login_page.dart';
import 'package:edi301/Register/register_page.dart';
import 'package:edi301/src/pages/Home/home_page.dart';
import 'package:edi301/src/pages/Family/familiy_page.dart';
import 'package:edi301/src/pages/Family/Edit/edit_page.dart';
import 'package:edi301/src/pages/News/news_page.dart';
import 'package:edi301/src/pages/Search/search_page.dart';
import 'package:edi301/src/pages/Admin/admin_page.dart';
import 'package:edi301/src/pages/Perfil/perfil_page.dart';
import 'package:edi301/src/pages/Admin/add_family/add_family_page.dart';
import 'package:edi301/src/pages/Admin/add_alumns/add_alumns_page.dart';
import 'package:edi301/src/pages/Admin/get_family/get_family_page.dart';
import 'package:edi301/src/pages/Admin/family_detail/Family_detail_page.dart';
import 'package:edi301/src/pages/Admin/studient_detail/studient_detail_page.dart';
import 'package:edi301/src/pages/Admin/agenda/agenda_page.dart';
import 'package:edi301/src/pages/Admin/agenda/crear_evento_page.dart';
import 'package:edi301/src/pages/Admin/agenda/agenda_detail_page.dart';
import 'package:edi301/src/pages/Admin/reportes/reportes_page.dart';
import 'package:edi301/src/theme_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadTheme();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Colores originales para el TEMA CLARO
    final Color primaryBlue = const Color.fromRGBO(19, 67, 107, 1);
    final Color accentYellow = const Color.fromRGBO(245, 188, 6, 1);

    // --- 1. DEFINIR TEMA OSCURO (TONOS GRISES) ---
    final Color darkSurface = Colors.grey[850]!; // #303030 (Cards, AppBars)
    final Color darkBackground = Colors.grey[900]!; // #212121 (Fondo)
    final Color lightGreyAccent = Colors.grey[700]!; // Acento para botones

    final ThemeData customDarkTheme = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: false,

      // Colores de fondo
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkSurface,

      // Esquema de color (TONOS GRISES)
      colorScheme: ColorScheme.dark(
        primary: lightGreyAccent, // Color principal (botones, switches)
        secondary: Colors.grey[800]!, // Color secundario
        background: darkBackground, // Fondo de la app
        surface: darkSurface, // Superficie de (Cards, AppBars, Dialogs)
        onPrimary: Colors.white, // Texto sobre botones grises
        onSurface: Colors.white, // Texto sobre cards/appbars
        onBackground: Colors.white, // Texto sobre el fondo
      ),

      // Tema para AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface, // <-- GRIS OSCURO
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Ícono de flecha atrás
        titleTextStyle: const TextStyle(
          // Título del AppBar
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Tema para Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurface, // <-- GRIS OSCURO
        selectedItemColor: Colors.white, // Ícono activo (Blanco)
        unselectedItemColor: Colors.grey[600], // Íconos inactivos (Gris)
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Tema para Botones Flotantes (FAB)
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lightGreyAccent, // Gris
        foregroundColor: Colors.white, // Blanco
      ),

      // Tema para Botones Elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightGreyAccent, // Gris
          foregroundColor: Colors.white, // Blanco
        ),
      ),

      // Tema para el Switch (como en la pág. de perfil)
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.white; // Encendido
          }
          return Colors.grey[400]; // Apagado
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.white.withOpacity(0.5); // Barra (encendido)
          }
          return Colors.grey[700]; // Barra (apagado)
        }),
      ),

      // Tema general de íconos
      iconTheme: const IconThemeData(color: Colors.white),
    );
    // --- FIN DEL TEMA PERSONALIZADO ---

    // 3. CONSTRUIR LA APP
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'EDI 301',

          // Tema de día (Light) - Este sí usa los colores de la marca
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.light(
              primary: primaryBlue,
              secondary: accentYellow,
              brightness: Brightness.light,
            ),
            useMaterial3: false,
          ),

          darkTheme: customDarkTheme, // <-- APLICA EL NUEVO TEMA GRIS

          themeMode: currentMode,

          initialRoute: 'login',
          routes: {
            'login': (context) => const LoginPage(),
            'register': (context) => const RegisterPage(),
            'home': (context) => const HomePage(),
            'family': (context) => const FamiliyPage(),
            'edit': (context) => const EditPage(),
            'news': (context) => const NewsPage(),
            'search': (context) => const SearchPage(),
            'admin': (context) => const AdminPage(),
            'perfil': (context) => const PerfilPage(),
            'add_family': (context) => const AddFamilyPage(),
            'add_alumns': (context) => const AddAlumnsPage(),
            'get_family': (context) => const GetFamilyPage(),
            'family_detail': (_) => const FamilyDetailPage(),
            'student_detail': (_) => const StudentDetailPage(),
            'agenda': (context) => const AgendaPage(),
            'crear_evento': (context) => const CrearEventoPage(),
            'agenda_detail': (context) => const AgendaDetailPage(),
            'reportes': (context) => const ReportesPage(),
          },
        );
      },
    );
  }
}
