import 'package:edi301/src/pages/Admin/add_alumns/add_alumns_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AddAlumnsPage extends StatefulWidget {
  const AddAlumnsPage({super.key});

  @override
  State<AddAlumnsPage> createState() => _AddAlumnsPageState();
}

class _AddAlumnsPageState extends State<AddAlumnsPage> {
  final AddAlumnsController _controller = AddAlumnsController();
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.init(context);
    });
  }

  String? selectedFamily; // Familia seleccionada
  List<Widget> alumnFields = []; // Campos dinámicos para los alumnos
  List<int> fieldKeys = []; // Claves únicas para los campos

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
            _textFieldSearchFamily(),
            const FilterOptions(options: ['Todos', 'Interno', 'Externo']),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Ingresa la matrícula de los alumnos:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ...alumnFields, // Mostrar los campos generados dinámicamente
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
                    final key = fieldKeys.length; // Generar clave única
                    fieldKeys.add(key);
                    alumnFields.add(_buildAlumnField(key));
                  });
                },
              ),
            ),
            _buttonSave(),
          ],
        ),
      ),
    );
  }

  Widget _textFieldSearchFamily() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar familia',
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
        onChanged: (value) {
          // Implementa la búsqueda de familias aquí
          print('Buscando familia: $value');
        },
      ),
    );
  }

  Widget _buildAlumnField(int key) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Matrícula del alumno ${key + 1}',
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              setState(() {
                // Eliminar campo y clave asociada
                int index = fieldKeys.indexOf(key);
                if (index != -1) {
                  alumnFields.removeAt(index);
                  fieldKeys.removeAt(index);
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
        onPressed: _controller.goToAdminPage,
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
}

class FilterOptions extends StatefulWidget {
  final List<String> options;

  const FilterOptions({super.key, required this.options});

  @override
  _FilterOptionsState createState() => _FilterOptionsState();
}

class _FilterOptionsState extends State<FilterOptions> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10, // Espacio horizontal entre los filtros
      children: widget.options.map((option) {
        return ChoiceChip(
          label: Text(option),
          labelStyle: TextStyle(
            color: selectedOption == option
                ? Colors.white
                : const Color.fromRGBO(19, 67, 107, 1),
          ),
          backgroundColor: Colors.white,
          selectedColor: const Color.fromRGBO(245, 188, 6, 1),
          selected: selectedOption == option,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color.fromRGBO(245, 188, 6, 1)),
          ),
          onSelected: (isSelected) {
            setState(() {
              selectedOption = isSelected ? option : null;
            });
          },
        );
      }).toList(),
    );
  }
}
