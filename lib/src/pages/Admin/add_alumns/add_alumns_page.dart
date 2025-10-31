// lib/src/pages/Admin/add_alumns/add_alumns_page.dart
import 'package:flutter/material.dart';
import 'package:edi301/models/family_model.dart';
import 'package:edi301/services/search_api.dart';
import 'add_alumns_controller.dart';

class AddAlumnsPage extends StatefulWidget {
  const AddAlumnsPage({super.key});

  @override
  State<AddAlumnsPage> createState() => _AddAlumnsPageState();
}

class _AddAlumnsPageState extends State<AddAlumnsPage> {
  final _controller = AddAlumnsController();
  Key _alumnAutocompleteKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _controller.init(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color.fromRGBO(19, 67, 107, 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignar Alumnos a Familia'),
        backgroundColor: primary,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFamilySelector(),
              const SizedBox(height: 30),
              const Text(
                'Buscar y Añadir Alumnos',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              _buildAlumnSelector(),
              const SizedBox(height: 20),
              _buildSelectedAlumnsList(),
              const SizedBox(height: 40),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFamilySelector() {
    return ValueListenableBuilder<Family?>(
      valueListenable: _controller.selectedFamily,
      builder: (context, selectedFamily, child) {
        return Autocomplete<Family>(
          displayStringForOption: (family) => family.familyName,
          optionsBuilder: (textEditingValue) {
            if (selectedFamily != null) {
              return const Iterable<Family>.empty();
            }
            return _controller.searchFamilies(textEditingValue.text);
          },
          onSelected: (family) {
            _controller.selectFamily(family);
            FocusScope.of(context).unfocus();
          },
          fieldViewBuilder:
              (context, textEditingController, focusNode, onFieldSubmitted) {
                if (selectedFamily != null) {
                  textEditingController.text = selectedFamily.familyName;
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Familia Seleccionada',
                      filled: true,
                      fillColor: Colors.grey[200],
                      prefixIcon: const Icon(Icons.family_restroom),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        tooltip: 'Cambiar familia',
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clearFamily();
                          textEditingController.clear();
                        },
                      ),
                    ),
                  );
                } else {
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: '1. Buscar familia por nombre',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              },
        );
      },
    );
  }

  Widget _buildAlumnSelector() {
    return Autocomplete<UserMini>(
      key: _alumnAutocompleteKey,
      displayStringForOption: (alumn) =>
          '${alumn.nombre} ${alumn.apellido} (${alumn.matricula ?? 'N/A'})',
      optionsBuilder: (textEditingValue) {
        return _controller.searchAlumns(textEditingValue.text);
      },
      // --- INICIO DE LA SOLUCIÓN DEFINITIVA ---
      onSelected: (alumn) {
        // 1. Añade el alumno a la lista de datos.
        _controller.addAlumn(alumn);

        // 2. Quita el foco del TextField de inmediato.
        FocusScope.of(context).unfocus();

        // 3. Usamos Future.microtask para posponer la reconstrucción del widget.
        //    Esto le da tiempo al sistema para procesar la pérdida de foco
        //    antes de que intentemos destruir el widget.
        Future.microtask(() {
          setState(() {
            _alumnAutocompleteKey = UniqueKey();
          });
        });
      },
      // --- FIN DE LA SOLUCIÓN DEFINITIVA ---
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: '2. Buscar alumno por matrícula o nombre',
                prefixIcon: const Icon(Icons.person_search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
    );
  }

  Widget _buildSelectedAlumnsList() {
    return ValueListenableBuilder<List<UserMini>>(
      valueListenable: _controller.selectedAlumns,
      builder: (context, alumns, child) {
        if (alumns.isEmpty) {
          return const Center(
            child: Text(
              'Ningún alumno añadido todavía.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: alumns
              .map(
                (alumn) => Chip(
                  label: Text('${alumn.nombre} ${alumn.apellido}'),
                  avatar: const Icon(Icons.school),
                  onDeleted: () => _controller.removeAlumn(alumn),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ValueListenableBuilder<bool>(
        valueListenable: _controller.loading,
        builder: (context, isLoading, child) {
          return ElevatedButton.icon(
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(isLoading ? 'GUARDANDO...' : 'GUARDAR ASIGNACIONES'),
            onPressed: isLoading ? null : _controller.saveAssignments,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(19, 67, 107, 1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }
}
