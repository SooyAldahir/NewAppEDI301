import 'dart:convert';
import 'package:edi301/core/api_client.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

    setState(() {
      data = {
        ...data,
        'name':
            '${(u['nombre'] ?? '').toString()} ${(u['apellido'] ?? '').toString()}'
                .trim()
                .isEmpty
            ? '—'
            : '${u['nombre'] ?? ''} ${u['apellido'] ?? ''}'.trim(),
        'email': (u['correo'] ?? '—').toString(),
        'matricula': (u['matricula'] ?? '—').toString(),
        'phone': (u['telefono'] ?? '—').toString(),
        'residence': (u['residencia'] ?? '—').toString(), // Interna | Externa
        'address': (u['direccion'] ?? '—').toString(),
        'birthday': (u['fecha_nacimiento'] ?? '—').toString(),
        'avatarUrl': (u['foto_perfil'] ?? data['avatarUrl']).toString(),
        'status': (u['estado'] ?? 'Activo').toString(),
        'grade': (u['carrera'] ?? '—').toString(), // para alumnos
      };
    });
  }

  // 2) (Opcional) Completa desde API /api/usuarios/:id para traer campos nuevos/actualizados
  Future<void> _fetchFromServer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('user');
      if (raw == null) return;
      final u = jsonDecode(raw) as Map<String, dynamic>;
      final id = u['id_usuario'];

      final dio = ApiClient().dio;
      final res = await dio.get(
        '/api/usuarios/$id',
      ); // ajusta si tu endpoint difiere
      final x = Map<String, dynamic>.from(res.data ?? {});

      setState(() {
        data = {
          ...data,
          'name':
              '${(x['nombre'] ?? u['nombre'] ?? '')} ${(x['apellido'] ?? u['apellido'] ?? '')}'
                  .trim()
                  .isEmpty
              ? data['name']
              : '${x['nombre'] ?? u['nombre'] ?? ''} ${(x['apellido'] ?? u['apellido'] ?? '')}',
          'email': (x['correo'] ?? u['correo'] ?? data['email']).toString(),
          'matricula': (x['matricula'] ?? u['matricula'] ?? data['matricula'])
              .toString(),
          'phone': (x['telefono'] ?? data['phone']).toString(),
          'residence': (x['residencia'] ?? data['residence']).toString(),
          'address': (x['direccion'] ?? data['address']).toString(),
          'birthday': (x['fecha_nacimiento'] ?? data['birthday']).toString(),
          'avatarUrl': (x['foto_perfil'] ?? data['avatarUrl']).toString(),
          'status': (x['estado'] ?? data['status']).toString(),
          'grade': (x['carrera'] ?? data['grade']).toString(),
          // 'family'  : podrías llenar con /api/miembros/familia o un endpoint /usuarios/:id/familia
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
    if (low.contains('inac') || low.contains('baja') || low.contains('suspend'))
      return Colors.red;
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
        // pull-to-refresh para re-cargar del server
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
    final p = primary; // alias corto

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          // para que el RefreshIndicator funcione incluso sin contenido
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
