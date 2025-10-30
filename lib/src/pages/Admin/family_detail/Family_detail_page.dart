// lib/src/pages/Admin/family_detail/family_detail_page.dart
import 'package:flutter/material.dart';
import 'package:edi301/src/pages/Admin/add_family/add_family_controller.dart';
import 'package:edi301/models/family_model.dart';

class FamilyDetailPage extends StatefulWidget {
  const FamilyDetailPage({super.key});

  @override
  State<FamilyDetailPage> createState() => _FamilyDetailPageState();
}

class _FamilyDetailPageState extends State<FamilyDetailPage> {
  Family? f;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is Family) {
      f = args;
    } else {
      // fallback: sal con mensaje si no llegó lo esperado
      Future.microtask(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir la familia')),
        );
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (f == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final fam = f!;
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
            items: fam.householdChildren,
            emptyText: 'Sin hijos registrados en casa.',
            buildTrailing: (child) => IconButton(
              tooltip: 'Eliminar',
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Si aún quieres soportar borrar aquí, necesitarías
                // una fuente de verdad para actualizar (id + endpoint o
                // un estado central). Por ahora, si tu lógica era local:
                // AddFamilyController.removeHouseholdChild(index, child);
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
                    arguments: student,
                  ),
                ),
                // Ídem comentario de “fuente de verdad” si quisieras eliminar aquí
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
              final result = await Navigator.pushNamed(
                context,
                'add_alumns',
                arguments: fam.familyName,
              );
              if (result == true && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alumnos agregados')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

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
            Text('Padre: ${f.fatherName}'),
            Text('Madre: ${f.motherName}'),
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Sin elementos',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...items.map(
              (e) => ListTile(
                dense: true,
                leading: Icon(leadingIcon),
                title: Text(e),
                trailing: buildTrailing(e), // 👈 acciones por tipo
              ),
            ),
        ],
      ),
    );
  }
}
