import 'package:edi301/src/theme_service.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadTheme(); // Carga el tema guardado

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // --- 1. DEFINIR COLORES ---
    final Color primaryBlue = const Color.fromRGBO(19, 67, 107, 1);
    final Color accentYellow = const Color.fromRGBO(245, 188, 6, 1);

    final Color darkSurface =
        Colors.grey[850]!; // #303030 (Para AppBars, Cards)
    final Color darkBackground = Colors.grey[900]!; // #212121 (Fondo principal)

    // --- 2. DEFINIR EL TEMA OSCURO PERSONALIZADO ---
    final ThemeData customDarkTheme = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: false,
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkSurface, // <-- ESTA LÍNEA ES LA CORRECTA
      colorScheme: ColorScheme.dark(
        primary: accentYellow,
        secondary: primaryBlue,
        background: darkBackground,
        surface: darkSurface,
        onPrimary: Colors.black,
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: accentYellow,
        unselectedItemColor: Colors.grey[500],
      ),

      // --- CORRECCIÓN AQUÍ ---

      // -----------------------
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentYellow,
        foregroundColor: Colors.black,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentYellow,
          foregroundColor: Colors.black,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return accentYellow;
          }
          return Colors.grey[400];
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return accentYellow.withOpacity(0.5);
          }
          return Colors.grey[700];
        }),
      ),
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

          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.light(
              primary: primaryBlue,
              secondary: accentYellow,
              brightness: Brightness.light,
            ),
            useMaterial3: false,
          ),

          darkTheme: customDarkTheme,
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
