import 'package:flutter/material.dart';
import 'package:edi301/src/pages/Admin/add_family/add_family_controller.dart';
import 'package:edi301/src/pages/Admin/get_family/family_model.dart';

class FamilyDetailPage extends StatelessWidget {
  const FamilyDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final int index = ModalRoute.of(context)!.settings.arguments as int;
    final Family f = AddFamilyController.familyList[index];

    return Scaffold(
      appBar: AppBar(
        title: Text(f.familyName),
        backgroundColor: const Color.fromRGBO(19, 67, 107, 1),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Header(f: f),
          const SizedBox(height: 16),
          _Section(
            title: 'Hijos en casa',
            items: f.householdChildren,
            emptyText: 'Sin hijos registrados en casa.',
            icon: Icons.family_restroom,
          ),
          const SizedBox(height: 12),
          _Section(
            title: 'Alumnos asignados',
            items: f.assignedStudents,
            emptyText: 'Sin alumnos asignados.',
            icon: Icons.school,
          ),
          const SizedBox(height: 24),

          // (Opcional) Ir a la pantalla de agregar alumnos con esta familia preseleccionada
          // Puedes implementar preselección si quieres; por ahora solo navega.
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
            onPressed: () => Navigator.pushNamed(context, 'add_alumns'),
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
    required this.icon,
  });

  final String title;
  final List<String> items;
  final String emptyText;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                emptyText,
                style: const TextStyle(color: Colors.grey),
              ),
            )
          else
            ...items.map(
              (e) => ListTile(dense: true, leading: Icon(icon), title: Text(e)),
            ),
        ],
      ),
    );
  }
}
