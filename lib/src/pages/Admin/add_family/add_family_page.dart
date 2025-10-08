import 'package:edi301/src/pages/Admin/add_family/add_family_controller.dart';
import 'package:edi301/src/pages/Admin/get_family/family_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AddFamilyPage extends StatefulWidget {
  const AddFamilyPage({super.key});

  @override
  State<AddFamilyPage> createState() => _AddFamilyPageState();
}

class _AddFamilyPageState extends State<AddFamilyPage> {
  final AddFamilyController _controller = AddFamilyController();
  // al inicio del _AddFamilyPageState
  final familyNameCtrl = TextEditingController();
  final fatherCtrl = TextEditingController();
  final motherCtrl = TextEditingController();
  final List<TextEditingController> childCtrls = [];

  static const Set<String> _surnameConnectors = {
    'de',
    'del',
    'la',
    'las',
    'los',
    'y',
    'da',
    'das',
    'do',
    'dos',
    'di',
    'van',
    'von',
    'bin',
    'ben',
    'san',
    'santa',
    'st',
    'st.',
  };

  String _titleCaseSurname(String s) {
    final parts = s.trim().split(RegExp(r'\s+'));
    return parts
        .map((p) {
          final low = p.toLowerCase();
          if (_surnameConnectors.contains(low)) return low;
          if (p.isEmpty) return p;
          return p[0].toUpperCase() + p.substring(1).toLowerCase();
        })
        .join(' ');
  }

  String _firstSurname(String fullName) {
    final toks = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
    if (toks.isEmpty) return '';

    int i = toks.length - 1;

    // 1) Grupo de apellido "materno" (último grupo)
    List<String> lastGroup = [toks[i]];
    i--;
    while (i >= 0 && _surnameConnectors.contains(toks[i].toLowerCase())) {
      lastGroup.insert(0, toks[i]);
      i--;
    }

    // 2) Grupo de apellido "paterno" (el anterior al último)
    if (i >= 0) {
      List<String> prevGroup = [toks[i]];
      i--;
      while (i >= 0 && _surnameConnectors.contains(toks[i].toLowerCase())) {
        prevGroup.insert(0, toks[i]);
        i--;
      }
      return _titleCaseSurname(prevGroup.join(' '));
    } else {
      // Si solo hay un apellido, usamos ese
      return _titleCaseSurname(lastGroup.join(' '));
    }
  }

  // Actualiza el campo "Nombre de la familia" automáticamente
  void _updateFamilyName() {
    final f = _firstSurname(fatherCtrl.text);
    final m = _firstSurname(motherCtrl.text);
    final parts = [f, m].where((x) => x.isNotEmpty).toList();
    final name = parts.isEmpty ? '' : 'Familia ${parts.join(' ')}';
    if (familyNameCtrl.text != name) {
      familyNameCtrl.text = name;
    }
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.init(context);
    });
    // 👇 Actualiza el nombre automáticamente cuando escribas papá/mamá
    fatherCtrl.addListener(_updateFamilyName);
    motherCtrl.addListener(_updateFamilyName);
    _updateFamilyName(); // inicial
  }

  bool hasChildren = false; // Control del Switch
  bool light0 = true;
  bool light1 = false;
  List<Widget> childrenFields = []; // Lista de campos dinámicos
  List<int> fieldKeys = []; // Lista de claves únicas para los campos

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromRGBO(19, 67, 107, 1),
        title: const Text('Regresar', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _textFieldFamilyName(),
            _textFieldSearchDad(),
            _textFieldSearchMom(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '¿Cuenta con hijos en casa?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: hasChildren,
                    activeThumbColor: const Color.fromRGBO(19, 67, 107, 1),
                    onChanged: (bool value) {
                      setState(() {
                        hasChildren = value;
                        if (!hasChildren) {
                          // limpia UI y controladores de hijos
                          for (final c in childCtrls) c.dispose();
                          childCtrls.clear();
                          childrenFields.clear();
                          fieldKeys.clear(); // opcional si lo sigues usando
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            if (hasChildren)
              Column(
                children: [
                  ...childrenFields, // Mostrar los campos generados
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        size: 40,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        setState(() {
                          final ctrl = TextEditingController();
                          childCtrls.add(ctrl);
                          final index = childCtrls.length - 1;
                          childrenFields.add(
                            _buildChildField(index, ctrl),
                          ); // 👈 pásale el ctrl
                        });
                      },
                    ),
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '¿La familia es interna?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: light1,
                    activeThumbColor: const Color.fromRGBO(19, 67, 107, 1),
                    onChanged: (bool value) {
                      setState(() {
                        light1 = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            _buttonSave(),
          ],
        ),
      ),
    );
  }

  Widget _buildChildField(int key, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              hintText: 'Ingrese nombre del hijo ${key + 1}',
              controller: ctrl, // ✅ ahora sí llega por parámetro
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                // ✅ Busca el índice REAL por el controller (evita índices viejos)
                final i = childCtrls.indexOf(ctrl);
                if (i != -1) {
                  childCtrls.removeAt(i);
                  childrenFields.removeAt(i);
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
        onPressed: () {
          final childrenValues = childCtrls
              .map((c) => c.text.trim())
              .where((t) => t.isNotEmpty)
              .toList();

          final family = Family(
            familyName: familyNameCtrl.text.trim(),
            fatherName: fatherCtrl.text.trim(),
            motherName: motherCtrl.text.trim(),
            residence: light1 ? "Interna" : "Externa",
            householdChildren: childCtrls
                .map((c) => c.text.trim())
                .where((t) => t.isNotEmpty)
                .toList(), // 👈 antes usabas `children:`
            // assignedStudents: [] // opcional; queda vacío por default
          );

          // Guarda en tu lista/controlador
          _controller.saveFamily(family);

          // Limpia (opcional, si prefieres) y navega reemplazando
          _clearForm(); // opcional
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, 'get_family');
        },
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

  void _clearForm() {
    familyNameCtrl.clear();
    fatherCtrl.clear();
    motherCtrl.clear();

    for (final c in childCtrls) {
      c.clear();
      c.dispose();
    }
    childCtrls.clear();
    childrenFields.clear();
    fieldKeys.clear(); // si ya no lo usas, puedes eliminar esa lista del todo

    hasChildren = false;
    light1 = false;

    setState(() {});
  }

  @override
  void dispose() {
    familyNameCtrl.dispose();
    fatherCtrl.dispose();
    motherCtrl.dispose();
    for (final c in childCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _textFieldFamilyName() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: TextField(
        controller: familyNameCtrl,
        readOnly: true,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          hintText: 'Nombre de la familia (ej. Familia Pérez López)',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color.fromRGBO(245, 188, 6, 1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              color: Color.fromRGBO(245, 188, 6, 1),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.all(15),
        ),
      ),
    );
  }

  Widget _textFieldSearchDad() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
      child: TextField(
        controller: fatherCtrl,
        decoration: InputDecoration(
          hintText: 'Asignar un papá',
          filled: true,
          fillColor: Colors.white, // Fondo blanco
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color.fromRGBO(245, 188, 6, 1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color.fromRGBO(245, 188, 6, 1)),
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
      ),
    );
  }

  Widget _textFieldSearchMom() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
      child: TextField(
        controller: motherCtrl,
        decoration: InputDecoration(
          hintText: 'Asignar una mamá',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color.fromRGBO(245, 188, 6, 1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color.fromRGBO(245, 188, 6, 1)),
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
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry? contentPadding;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.hintStyle,
    this.contentPadding,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color.fromRGBO(245, 188, 6, 1), width: 2),
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: hintStyle ?? const TextStyle(color: Colors.black),
          border: InputBorder.none,
          contentPadding: contentPadding ?? const EdgeInsets.all(15),
        ),
      ),
    );
  }
}
