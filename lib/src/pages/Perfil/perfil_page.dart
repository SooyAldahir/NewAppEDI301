import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edi301/core/api_client_http.dart';
import 'package:edi301/src/pages/Perfil/perfil_widgets.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  // Datos base (fallbacks)
  Map<String, dynamic> data = {
    'name': '—',
    'matricula': '—',
    'phone': '—',
    'email': '—',
    'residence': '—', // 'Interna' | 'Externa'
    'family': '—',
    'address': '—',
    'birthday': '—',
    'avatarUrl': 'https://cdn-icons-png.flaticon.com/512/7141/7141724.png',
    'status': 'Activo',
    'grade': '—',
  };

  bool notif = true;
  bool darkMode = false;
  bool showAvatar = true;
  bool bgRefresh = true;
  bool birthdayReminder = true;

  bool _loading = true;
  final primary = const Color.fromRGBO(19, 67, 107, 1);

  final ApiHttp _http = ApiHttp();

  @override
  void initState() {
    super.initState();
    _loadProfile(); // hidrata desde local y servidor
  }

  // 1) Lee 'user' de SharedPreferences y mapea a tu UI
  Future<void> _hydrateFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('user');
    if (raw == null) return;
    final u = jsonDecode(raw) as Map<String, dynamic>;

    String nombre = (u['nombre'] ?? u['Nombre'] ?? '').toString();
    String apellido = (u['apellido'] ?? u['Apellido'] ?? '').toString();

    setState(() {
      data = {
        ...data,
        'name': (('$nombre $apellido').trim().isEmpty)
            ? '—'
            : ('$nombre $apellido').trim(),
        'email': (u['correo'] ?? u['E_mail'] ?? '—').toString(),
        'matricula': (u['matricula'] ?? u['Matricula'] ?? '—').toString(),
        'phone': (u['telefono'] ?? u['Telefono'] ?? '—').toString(),
        'residence': (u['residencia'] ?? u['Residencia'] ?? '—').toString(),
        'address': (u['direccion'] ?? u['Direccion'] ?? '—').toString(),
        'birthday': (u['fecha_nacimiento'] ?? u['Fecha_Nacimiento'] ?? '—')
            .toString(),
        'avatarUrl': (u['foto_perfil'] ?? u['FotoPerfil'] ?? data['avatarUrl'])
            .toString(),
        'status': (u['estado'] ?? u['Estado'] ?? 'Activo').toString(),
        'grade': (u['carrera'] ?? '—').toString(), // para alumnos
      };
    });
  }

  // 2) Completa desde API /api/users/:id para traer campos nuevos/actualizados
  Future<void> _fetchFromServer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('user');
      if (raw == null) return;
      final u = jsonDecode(raw) as Map<String, dynamic>;
      final id = u['IdUsuario'] ?? u['id_usuario'] ?? u['id'] ?? u['Id'];

      if (id == null) return;

      final res = await _http.getJson(
        '/api/users/$id',
      ); // ajusta si tu endpoint difiere
      if (res.statusCode >= 400) return;

      final x = jsonDecode(res.body) as Map<String, dynamic>;

      String nombre = (x['nombre'] ?? x['Nombre'] ?? u['nombre'] ?? '')
          .toString();
      String apellido = (x['apellido'] ?? x['Apellido'] ?? u['apellido'] ?? '')
          .toString();

      setState(() {
        data = {
          ...data,
          'name': (('$nombre $apellido').trim().isEmpty)
              ? data['name']
              : ('$nombre $apellido').trim(),
          'email': (x['correo'] ?? x['E_mail'] ?? data['email']).toString(),
          'matricula': (x['matricula'] ?? x['Matricula'] ?? data['matricula'])
              .toString(),
          'phone': (x['telefono'] ?? x['Telefono'] ?? data['phone']).toString(),
          'residence': (x['residencia'] ?? x['Residencia'] ?? data['residence'])
              .toString(),
          'address': (x['direccion'] ?? x['Direccion'] ?? data['address'])
              .toString(),
          'birthday':
              (x['fecha_nacimiento'] ??
                      x['Fecha_Nacimiento'] ??
                      data['birthday'])
                  .toString(),
          'avatarUrl':
              (x['foto_perfil'] ?? x['FotoPerfil'] ?? data['avatarUrl'])
                  .toString(),
          'status': (x['estado'] ?? x['Estado'] ?? data['status']).toString(),
          'grade': (x['carrera'] ?? data['grade']).toString(),
          // 'family': podrías llenar con /api/users/:id/familia si existe
        };
      });
    } catch (_) {
      // silencioso; nos quedamos con lo local
    }
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    await _hydrateFromLocal();
    await _fetchFromServer(); // comenta esta línea si aún no tienes el endpoint
    setState(() => _loading = false);
  }

  // ===== helpers UI existentes =====
  String s(String k, [String d = '—']) {
    final v = data[k];
    if (v == null) return d;
    final t = v.toString().trim();
    return t.isEmpty ? d : t;
  }

  bool get isInternal => s('residence').toLowerCase().startsWith('intern');

  Color _statusColor(String st) {
    final low = st.toLowerCase();
    if (low.contains('inac') ||
        low.contains('baja') ||
        low.contains('suspend')) {
      return Colors.red;
    }
    if (low.contains('pend') || low.contains('proce')) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final content = _loading
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        : _buildContent(context);

    return Scaffold(
      backgroundColor: const Color(0xfff7f8fa),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              title: const Text('Mi perfil'),
              backgroundColor: primary,
              automaticallyImplyLeading: false,
              elevation: 0,
              floating: true,
              snap: true,
              actions: [
                IconButton(
                  tooltip: 'Editar perfil',
                  icon: const Icon(Icons.edit),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Editar perfil (pendiente)')),
                  ),
                ),
              ],
            ),
          ],
          body: content,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final p = primary;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            HeaderCard(
              name: s('name'),
              family: s('family'),
              residence: s('residence'),
              status: s('status', 'Activo'),
              avatarUrl: s('avatarUrl'),
              showAvatar: showAvatar,
              primary: p,
              statusColor: _statusColor(s('status', 'Activo')),
              onToggleAvatar: (v) => setState(() => showAvatar = v),
            ),
            const SizedBox(height: 12),

            SectionCard(
              title: 'Datos',
              primary: p,
              children: [
                InfoRow(
                  icon: Icons.badge_outlined,
                  label: 'Matrícula',
                  value: s('matricula'),
                ),
                InfoRow(
                  icon: Icons.school_outlined,
                  label: 'Programa',
                  value: s('grade'),
                ),
                InfoRow(
                  icon: Icons.cake_outlined,
                  label: 'Cumpleaños',
                  value: s('birthday'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            SectionCard(
              title: 'Contacto',
              primary: p,
              children: [
                InfoRow(
                  icon: Icons.call_outlined,
                  label: 'Teléfono',
                  value: s('phone'),
                ),
                InfoRow(
                  icon: Icons.mail_outline,
                  label: 'Correo',
                  value: s('email'),
                ),
                if (!isInternal)
                  InfoRow(
                    icon: Icons.home_outlined,
                    label: 'Dirección',
                    value: s('address'),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            SettingsCard(
              primary: p,
              notif: notif,
              darkMode: darkMode,
              showAvatar: showAvatar,
              bgRefresh: bgRefresh,
              birthdayReminder: birthdayReminder,
              onChanged: (k, v) => setState(() {
                switch (k) {
                  case 'notif':
                    notif = v;
                    break;
                  case 'dark':
                    darkMode = v;
                    break;
                  case 'avatar':
                    showAvatar = v;
                    break;
                  case 'bg':
                    bgRefresh = v;
                    break;
                  case 'bd':
                    birthdayReminder = v;
                    break;
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
