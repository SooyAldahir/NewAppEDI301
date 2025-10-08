import 'package:edi301/src/pages/Admin/add_alumns/add_alumns_controller.dart';
import 'package:edi301/src/pages/Admin/add_family/add_family_controller.dart';
import 'package:edi301/src/pages/Admin/get_family/family_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AddAlumnsPage extends StatefulWidget {
  const AddAlumnsPage({super.key});

  @override
  State<AddAlumnsPage> createState() => _AddAlumnsPageState();
}

class _AddAlumnsPageState extends State<AddAlumnsPage> {
  final AddAlumnsController _controller = AddAlumnsController();

  // Buscador/selección de familia
  final TextEditingController searchFamilyCtrl = TextEditingController();
  String? selectedFamily;

  // Matrículas dinámicas
  final List<TextEditingController> studentCtrls = [];
  final List<Widget> alumnFields = [];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.init(context);
    });
  }

  @override
  void dispose() {
    searchFamilyCtrl.dispose();
    for (final c in studentCtrls) c.dispose();
    super.dispose();
  }

  List<Family> get allFamilies => AddFamilyController.familyList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regresar'),
        backgroundColor: const Color.fromRGBO(19, 67, 107, 1),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _familyAutocomplete(),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Ingresa la matrícula de los alumnos:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ...alumnFields,
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  size: 40,
                  color: Colors.amber,
                ),
                onPressed: _addStudentField,
              ),
            ),
            _buttonSave(),
          ],
        ),
      ),
    );
  }

  // ================== UI ==================

  Widget _familyAutocomplete() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
      child: Autocomplete<Family>(
        optionsBuilder: (TextEditingValue text) {
          final q = text.text.trim().toLowerCase();
          if (q.isEmpty) return const Iterable<Family>.empty();
          return allFamilies.where(
            (f) => f.familyName.toLowerCase().contains(q),
          );
        },
        displayStringForOption: (Family f) => f.familyName,
        onSelected: (Family f) {
          setState(() {
            selectedFamily = f.familyName;
            searchFamilyCtrl.text = f.familyName;
          });
        },
        fieldViewBuilder:
            (context, textController, focusNode, onFieldSubmitted) {
              // sincroniza con nuestro controller
              textController.text = searchFamilyCtrl.text;
              textController.addListener(() {
                searchFamilyCtrl.text = textController.text;
              });
              return TextField(
                controller: textController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: 'Buscar familia',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(245, 188, 6, 1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(245, 188, 6, 1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(245, 188, 6, 1),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(15),
                  suffixIcon: const Icon(
                    Icons.search,
                    color: Color.fromRGBO(19, 67, 107, 1),
                  ),
                ),
              );
            },
        optionsViewBuilder: (context, onSelected, options) {
          final opts = options.toList();
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 240,
                  maxWidth: 600,
                ),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: opts.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final f = opts[index];
                    return ListTile(
                      title: Text(f.familyName),
                      subtitle: Text(
                        'Padre: ${f.fatherName} • Madre: ${f.motherName}',
                      ),
                      onTap: () => onSelected(f),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _addStudentField() {
    setState(() {
      final ctrl = TextEditingController();
      studentCtrls.add(ctrl);
      final index = studentCtrls.length - 1;
      alumnFields.add(_buildAlumnField(index, ctrl));
    });
  }

  Widget _buildAlumnField(int index, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: ctrl,
              decoration: InputDecoration(
                hintText: 'Matrícula del alumno ${index + 1}',
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                final i = studentCtrls.indexOf(ctrl);
                if (i != -1) {
                  studentCtrls.removeAt(i);
                  alumnFields.removeAt(i);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buttonSave() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: ElevatedButton(
        onPressed: _onSave,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: const Color.fromRGBO(245, 188, 6, 1),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: const Text(
          'GUARDAR',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  // ================== LÓGICA ==================

  void _onSave() {
    final famName = (selectedFamily ?? searchFamilyCtrl.text).trim();
    if (famName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona una familia')));
      return;
    }

    final students = studentCtrls
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos una matrícula')),
      );
      return;
    }

    final ok = AddFamilyController.addStudentsToFamily(famName, students);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se encontró la familia "$famName"')),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Alumnos agregados a $famName')));

    // Limpia y navega a la lista/búsqueda
    _clearForm();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, 'get_family');
  }

  void _clearForm() {
    selectedFamily = null;
    searchFamilyCtrl.clear();
    for (final c in studentCtrls) c.dispose();
    studentCtrls.clear();
    alumnFields.clear();
    setState(() {});
  }
}
