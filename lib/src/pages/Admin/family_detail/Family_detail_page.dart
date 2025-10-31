// lib/src/pages/Admin/family_detail/Family_detail_page.dart
import 'package:flutter/material.dart';
import 'package:edi301/models/family_model.dart';
import 'package:edi301/services/familia_api.dart';

class FamilyDetailPage extends StatefulWidget {
  const FamilyDetailPage({super.key});

  @override
  State<FamilyDetailPage> createState() => _FamilyDetailPageState();
}

class _FamilyDetailPageState extends State<FamilyDetailPage> {
  Family? _family;
  bool _isLoading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Solo cargamos los datos la primera vez que se construye el widget
    if (_isLoading) {
      final args = ModalRoute.of(context)!.settings.arguments;

      // Obtenemos el ID de la familia que se pasó como argumento
      int? familyId;
      if (args is Family) {
        familyId = args.id;
      } else if (args is int) {
        // Por si se pasa solo el ID
        familyId = args;
      }

      if (familyId != null) {
        _fetchFamilyDetails(familyId);
      } else {
        // Si no hay ID, mostramos un error
        setState(() {
          _isLoading = false;
          _error = 'No se pudo cargar la familia. ID no encontrado.';
        });
      }
    }
  }

  Future<void> _fetchFamilyDetails(int familyId) async {
    try {
      final api = FamiliaApi();
      // Hacemos la llamada a la API para obtener los datos completos
      final familyData = await api.getById(familyId);
      if (mounted) {
        setState(() {
          _family = Family.fromJson(familyData!);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Error al cargar los detalles: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cargando Familia...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(_error!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    final fam = _family!;
    return Scaffold(
      appBar: AppBar(
        title: Text(fam.familyName),
        backgroundColor: const Color.fromRGBO(19, 67, 107, 1),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Header(f: fam),
          const SizedBox(height: 16),
          _Section(
            title: 'Hijos en casa',
            items: fam.householdChildren, // ¡Ahora esta lista tendrá datos!
            emptyText: 'Sin hijos registrados en casa.',
            buildTrailing: (child) => IconButton(
              tooltip: 'Eliminar',
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Lógica para eliminar (futuro)
              },
            ),
            leadingIcon: Icons.family_restroom,
          ),
          const SizedBox(height: 12),
          _Section(
            title: 'Alumnos asignados',
            items: fam.assignedStudents,
            emptyText: 'Sin alumnos asignados.',
            buildTrailing: (student) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Ver detalles',
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => Navigator.pushNamed(
                    context,
                    'student_detail',
                    arguments: {'name': student},
                  ),
                ),
              ],
            ),
            leadingIcon: Icons.school,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.person_add),
            label: const Text('Agregar alumnos a esta familia'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(245, 188, 6, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () async {
              // Navegar para agregar más alumnos
            },
          ),
        ],
      ),
    );
  }
}

// WIDGETS AUXILIARES (sin cambios)
class _Header extends StatelessWidget {
  const _Header({required this.f});
  final Family f;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(f.familyName, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Padre: ${f.fatherName ?? "No asignado"}'),
            Text('Madre: ${f.motherName ?? "No asignada"}'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.home, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Residencia: ${f.residence}',
                  style: TextStyle(
                    color: f.residence == 'Interna' ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.items,
    required this.emptyText,
    required this.buildTrailing,
    required this.leadingIcon,
  });

  final String title;
  final List<String> items;
  final String emptyText;
  final Widget Function(String item) buildTrailing;
  final IconData leadingIcon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
        children: [
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: Text(
                emptyText,
                style: const TextStyle(color: Colors.grey),
              ),
            )
          else
            ...items.map(
              (e) => ListTile(
                dense: true,
                leading: Icon(leadingIcon),
                title: Text(e),
                trailing: buildTrailing(e),
              ),
            ),
        ],
      ),
    );
  }
}
