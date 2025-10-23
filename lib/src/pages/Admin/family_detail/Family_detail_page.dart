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
  late int index;
  late Family f;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    index = ModalRoute.of(context)!.settings.arguments as int;
    f = AddFamilyController.familyList.value[index]; // <-- aquí
  }

  Future<void> _confirmDelete({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // evita cierre tocando fuera
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) onConfirm();
  }

  Future<void> _goToAddStudents() async {
    final result = await Navigator.pushNamed(
      context,
      'add_alumns',
      arguments: f.familyName, // 👈 familia preseleccionada
    );

    if (result == true && mounted) {
      setState(() {
        // la lista estática ya se modificó; solo refrescamos la UI
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Alumnos agregados')));
    }
  }

  void _removeHousehold(String child) {
    _confirmDelete(
      title: 'Eliminar hijo en casa',
      message: '¿Eliminar "$child" de Hijos en casa?',
      onConfirm: () {
        AddFamilyController.removeHouseholdChild(index, child);
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Se eliminó "$child" de hijos en casa')),
        );
      },
    );
  }

  void _removeAssigned(String student) {
    _confirmDelete(
      title: 'Eliminar alumno asignado',
      message: '¿Eliminar "$student" de Alumnos asignados?',
      onConfirm: () {
        AddFamilyController.removeAssignedStudent(index, student);
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Se eliminó "$student" de alumnos asignados')),
        );
      },
    );
  }

  void _viewStudent(String student) {
    // página de detalle de alumno (puedes ajustarla a tu modelo real)
    Navigator.pushNamed(context, 'student_detail', arguments: student);
  }

  @override
  Widget build(BuildContext context) {
    // refrescar ref por si la lista cambió
    f = AddFamilyController.familyList.value[index];

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
            buildTrailing: (child) => IconButton(
              tooltip: 'Eliminar',
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeHousehold(child),
            ),
            leadingIcon: Icons.family_restroom,
          ),
          const SizedBox(height: 12),
          _Section(
            title: 'Alumnos asignados',
            items: f.assignedStudents,
            emptyText: 'Sin alumnos asignados.',
            buildTrailing: (student) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Ver detalles',
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => _viewStudent(student),
                ),
                IconButton(
                  tooltip: 'Eliminar',
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeAssigned(student),
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
            onPressed: _goToAddStudents,
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
