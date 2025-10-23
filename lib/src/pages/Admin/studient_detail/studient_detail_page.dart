// lib/src/pages/Admin/student_detail/student_detail_page.dart
import 'package:flutter/material.dart';
import 'package:edi301/src/pages/Admin/add_family/add_family_controller.dart';
import 'package:edi301/models/family_model.dart';

class StudentDetailPage extends StatelessWidget {
  const StudentDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dynamic args = ModalRoute.of(context)!.settings.arguments;

    // Soporta String (solo nombre) o Map<String, dynamic> con más datos
    final Map<String, dynamic> data = switch (args) {
      final String name => {'name': name},
      final Map<String, dynamic> m => m,
      _ => <String, dynamic>{},
    };

    String s(String k, [String d = '—']) {
      final v = data[k];
      if (v == null) return d;
      final t = v.toString().trim();
      return t.isEmpty ? d : t;
    }

    final theme = Theme.of(context);
    final primary = const Color.fromRGBO(19, 67, 107, 1);

    // Datos base (los que puedas pasar en arguments)
    final name = s('name');
    final phone = s('phone');
    final matricula = s('matricula');
    final birthday = s('birthday');
    final status = s('status', 'Activo');
    final grade = s('grade');
    final email = s('email');
    final rawAddr = s('address');
    final docLabel = s('docLabel', 'Matrícula');
    final docValue = s('docValue', s('matricula')); // fallback a 'matricula'

    // Si llega familyIndex, tomamos familia+residencia desde el controlador
    final int? familyIdx = (data['familyIndex'] is int)
        ? data['familyIndex'] as int
        : null;
    Family? fam;
    final all = AddFamilyController.familyList.value;
    if (familyIdx != null && familyIdx >= 0 && familyIdx < all.length) {
      fam = all[familyIdx];
    }

    // Familia y Residencia efectivas
    final familyName = s('familyName', fam?.familyName ?? '—');
    final residence = s('residence', fam?.residence ?? '—');

    final bool isInternal = residence.toLowerCase().startsWith('intern');
    // Mostrar dirección solo si es EXTERNO y hay dato
    final bool showAddress = !isInternal && rawAddr != '—';

    Color statusColor(String st) {
      final low = st.toLowerCase();
      if (low.contains('inac') ||
          low.contains('baja') ||
          low.contains('suspend')) {
        return Colors.red;
      }
      if (low.contains('pend') || low.contains('proce')) {
        return Colors.orange;
      }
      return Colors.green;
    }

    Widget sectionCard({
      required String title,
      required List<Widget> children,
    }) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      );
    }

    Widget infoTile(
      IconData icon,
      String label,
      String value, {
      VoidCallback? onTap,
    }) {
      final content = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 2),
                SelectableText(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      );
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: onTap != null
            ? InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onTap,
                child: content,
              )
            : content,
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        title: const Text('Detalle del alumno'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // PERFIL
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: primary.withOpacity(.1),
                      child: const Icon(
                        Icons.person,
                        size: 28,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: -8,
                            children: [
                              Chip(
                                label: Text(status),
                                backgroundColor: statusColor(
                                  status,
                                ).withOpacity(.15),
                                labelStyle: TextStyle(
                                  color: statusColor(status),
                                  fontWeight: FontWeight.w600,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                              Chip(
                                label: Text('Residencia: $residence'),
                                visualDensity: VisualDensity.compact,
                              ),
                              if (familyName != '—')
                                Chip(
                                  label: Text('Familia: $familyName'),
                                  visualDensity: VisualDensity.compact,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // CONTACTO
            sectionCard(
              title: 'Contacto',
              children: [
                infoTile(Icons.badge_outlined, docLabel, docValue),
                infoTile(
                  Icons.call_outlined,
                  'Teléfono',
                  phone,
                  onTap: phone == '—'
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Llamar a $phone')),
                          );
                        },
                ),
                infoTile(Icons.mail_outline, 'Correo', email),
                if (showAddress)
                  infoTile(Icons.home_outlined, 'Dirección', rawAddr),
              ],
            ),

            const SizedBox(height: 12),

            // ACADÉMICO
            sectionCard(
              title: 'Académico',
              children: [
                infoTile(Icons.cake_outlined, 'Cumpleaños', birthday),
                infoTile(Icons.school_outlined, 'Grado', grade),
                // 👇 Antes decía "Grupo"; ahora muestra "Familia"
                infoTile(Icons.family_restroom, 'Familia', familyName),
              ],
            ),

            const SizedBox(height: 12),

            // ACCIONES
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.call),
                        label: const Text('Llamar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: phone == '—'
                            ? null
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Llamar a $phone')),
                                );
                              },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.message_outlined),
                        label: const Text('Mensaje'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primary,
                          side: BorderSide(color: primary, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: phone == '—'
                            ? null
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Enviar mensaje a $phone'),
                                  ),
                                );
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            if (familyIdx != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Ver familia'),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      'family_detail',
                      arguments: familyIdx,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
