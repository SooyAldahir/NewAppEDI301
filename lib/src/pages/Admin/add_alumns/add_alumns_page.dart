import 'package:edi301/src/pages/Admin/add_alumns/add_alumns_controller.dart';
import 'package:edi301/src/pages/Admin/add_family/add_family_controller.dart';
import 'package:edi301/models/family_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AddAlumnsPage extends StatefulWidget {
  const AddAlumnsPage({super.key});

  @override
  State<AddAlumnsPage> createState() => _AddAlumnsPageState();
}

class _AddAlumnsPageState extends State<AddAlumnsPage> {
  late final AddAlumnsController _controller;

  // Buscador/selección de familia
  final TextEditingController searchFamilyCtrl = TextEditingController();
  Family? _selectedFamily; // << ahora guardamos el objeto (con id)
  bool _lockedFamily = false;

  // Matrículas dinámicas
  final List<TextEditingController> studentCtrls = [];
  final List<Widget> alumnFields = [];

  @override
  void initState() {
    super.initState();
    _controller = AddAlumnsController();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controller.init(context);
      // lee argumento opcional; puede venir el nombre de familia
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is String && args.isNotEmpty) {
        // intenta resolver el objeto Family por nombre
        final fam = _resolveFamilyByName(args);
        if (fam != null) {
          setState(() {
            _selectedFamily = fam;
            searchFamilyCtrl.text = fam.familyName;
            _lockedFamily = true; // bloquear edición si vino preseleccionada
          });
        } else {
          // si no se encontró, al menos bloqueamos el texto que vino
          setState(() {
            searchFamilyCtrl.text = args;
            _lockedFamily = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    searchFamilyCtrl.dispose();
    for (final c in studentCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  List<Family> get allFamilies => AddFamilyController.familyList.value;

  Family? _resolveFamilyByName(String name) {
    final low = name.trim().toLowerCase();
    return allFamilies.firstWhere(
      (f) => f.familyName.trim().toLowerCase() == low,
      orElse: () => null as Family,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color.fromRGBO(19, 67, 107, 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir alumnos a familia'),
        backgroundColor: primary,
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
    if (_lockedFamily) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
        child: TextField(
          controller: searchFamilyCtrl,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Familia seleccionada',
            suffixIcon: const Icon(Icons.lock),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color.fromRGBO(245, 188, 6, 1),
              ),
            ),
          ),
        ),
      );
    }

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
            _selectedFamily = f;
            searchFamilyCtrl.text = f.familyName;
          });
        },
        fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
          textController.text = searchFamilyCtrl.text;
          textController.addListener(() {
            searchFamilyCtrl.text = textController.text;
            // si el texto ya no coincide con la familia seleccionada, la des-seleccionamos
            if (_selectedFamily != null &&
                _selectedFamily!.familyName.toLowerCase() !=
                    textController.text.toLowerCase()) {
              _selectedFamily = null;
            }
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
              keyboardType: TextInputType.number,
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
    return ValueListenableBuilder<bool>(
      valueListenable: _controller.loading,
      builder: (_, isLoading, __) => Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: ElevatedButton(
          onPressed: isLoading ? null : _onSave,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            backgroundColor: const Color.fromRGBO(245, 188, 6, 1),
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          child: Text(
            isLoading ? 'Guardando...' : 'GUARDAR',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  // ================== LÓGICA ==================

  Future<void> _onSave() async {
    final fam = _selectedFamily ?? _resolveFamilyByName(searchFamilyCtrl.text);
    if (fam == null) {
      _snack('Selecciona una familia válida');
      return;
    }

    final students = studentCtrls
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (students.isEmpty) {
      _snack('Agrega al menos una matrícula');
      return;
    }

    final result = await _controller.addAlumnsToFamily(
      familyId: fam.id ?? 0, // usa el campo que tengas en tu model
      matriculas: students,
    );

    if (result.added.isNotEmpty) {
      _snack('Agregados: ${result.added.join(', ')}');
    }
    if (result.notFound.isNotEmpty || result.errors.isNotEmpty) {
      _snack(
        'No encontrados: ${result.notFound.join(', ')}. '
        'Errores: ${result.errors.join(', ')}',
      );
    }

    if (result.added.isNotEmpty) {
      if (mounted) {
        Navigator.pop(context, true); // vuelve al detalle y refresca
      }
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }
}
