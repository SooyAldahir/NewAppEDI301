// lib/src/pages/Family/familiy_page.dart
import 'package:flutter/material.dart';
import 'package:edi301/src/pages/Family/family_controller.dart';
import 'package:edi301/models/family_model.dart';
import 'package:edi301/core/api_client_http.dart'; // <-- Importar para la URL base
import 'package:image_picker/image_picker.dart'; // <-- Importar

class FamiliyPage extends StatefulWidget {
  const FamiliyPage({super.key});

  @override
  State<FamiliyPage> createState() => _FamiliyPageState();
}

class _FamiliyPageState extends State<FamiliyPage> {
  final _controller = FamilyController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadMyFamily(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- AÑADIR FUNCIÓN HELPER ---
  void _onEditPhoto(bool isCover) async {
    final source = await _controller.showImageSource(context);
    if (source == null || !mounted) return;
    _controller.pickAndUploadImage(context, source, isCover: isCover);
  }
  // -----------------------------

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _controller.loading,
      builder: (context, isLoading, _) {
        return ValueListenableBuilder<String?>(
          valueListenable: _controller.error,
          builder: (context, error, _) {
            if (isLoading && _controller.family.value == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (error != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('Error: $error', textAlign: TextAlign.center),
                ),
              );
            }
            if (_controller.family.value == null) {
              return const Center(child: Text('No se encontró la familia.'));
            }

            final family = _controller.family.value!;

            return RefreshIndicator(
              onRefresh: () => _controller.loadMyFamily(context),
              child: ListView(
                children: [
                  // --- HEADER (MODIFICADO) ---
                  _Header(
                    family: family,
                    onEditCover: () => _onEditPhoto(true),
                    onEditProfile: () => _onEditPhoto(false),
                  ),
                  // ---------------------------
                  _Title(family: family),
                  _AssignedKids(kids: family.assignedStudents),
                  _FamilyKids(kids: family.householdChildren),
                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// --- WIDGET DE CABECERA (RECONSTRUIDO) ---
class _Header extends StatelessWidget {
  final Family family;
  final VoidCallback onEditCover;
  final VoidCallback onEditProfile;

  const _Header({
    required this.family,
    required this.onEditCover,
    required this.onEditProfile,
  });

  // Helper para construir la URL completa
  String? _buildUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    return '${ApiHttp._baseUrl}$path';
  }

  @override
  Widget build(BuildContext context) {
    final coverUrl = _buildUrl(family.fotoPortadaUrl);
    final profileUrl = _buildUrl(family.fotoPerfilUrl);
    final theme = Theme.of(context);

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomLeft,
      children: [
        // --- 1. FOTO DE PORTADA ---
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            image: coverUrl != null
                ? DecorationImage(
                    image: NetworkImage(coverUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: coverUrl == null
              ? const Icon(Icons.image_outlined, size: 80, color: Colors.grey)
              : null,
        ),

        // --- 2. BOTÓN DE EDITAR PORTADA ---
        Positioned(
          top: 10,
          right: 10,
          child: _EditButton(
            onPressed: onEditCover,
            tooltip: 'Cambiar foto de portada',
          ),
        ),

        // --- 3. FOTO DE PERFIL ---
        Positioned(
          bottom: -40, // Mitad fuera
          left: 20,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: theme.scaffoldBackgroundColor,
                child: CircleAvatar(
                  radius: 46,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  backgroundImage: profileUrl != null
                      ? NetworkImage(profileUrl)
                      : null,
                  child: profileUrl == null
                      ? const Icon(
                          Icons.family_restroom,
                          size: 40,
                          color: Colors.grey,
                        )
                      : null,
                ),
              ),
              // --- 4. BOTÓN DE EDITAR PERFIL ---
              Positioned(
                bottom: 0,
                right: 0,
                child: _EditButton(
                  onPressed: onEditProfile,
                  tooltip: 'Cambiar foto de perfil',
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Widget auxiliar para el botón de editar
class _EditButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String tooltip;
  final double size;
  const _EditButton({
    required this.onPressed,
    required this.tooltip,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.5),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Icon(Icons.edit, size: size, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
// --- FIN DE WIDGETS DE CABECERA ---

// --- WIDGETS EXISTENTES (SIN CAMBIOS) ---
class _Title extends StatelessWidget {
  const _Title({required this.family});
  final Family family;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 55, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            family.familyName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 8),
          _infoRow(Icons.person, 'Papá: ${family.fatherName ?? "No asignado"}'),
          _infoRow(
            Icons.person_outline,
            'Mamá: ${family.motherName ?? "No asignada"}',
          ),
          _infoRow(
            Icons.home_work_outlined,
            'Residencia: ${family.residencia ?? "No asignada"}',
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}

class _AssignedKids extends StatelessWidget {
  const _AssignedKids({required this.kids});
  final List<FamilyMember> kids;
  @override
  Widget build(BuildContext context) {
    return _KidsSection(
      title: 'Hijos EDI (Alumnos Asignados)',
      kids: kids,
      icon: Icons.school,
      color: Colors.blue[50]!,
    );
  }
}

class _FamilyKids extends StatelessWidget {
  const _FamilyKids({required this.kids});
  final List<FamilyMember> kids;
  @override
  Widget build(BuildContext context) {
    return _KidsSection(
      title: 'Hijos en Casa',
      kids: kids,
      icon: Icons.home,
      color: Colors.green[50]!,
    );
  }
}

class _KidsSection extends StatelessWidget {
  const _KidsSection({
    required this.title,
    required this.kids,
    required this.icon,
    required this.color,
  });
  final String title;
  final List<FamilyMember> kids;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: color,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Divider(),
              if (kids.isEmpty) const Text('No hay hijos en esta sección.'),
              ...kids.map(
                (kid) => ListTile(
                  leading: CircleAvatar(child: Icon(icon)),
                  title: Text(kid.fullName),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
