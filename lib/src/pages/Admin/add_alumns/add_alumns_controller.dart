// lib/src/pages/Admin/add_alumns/add_alumns_controller.dart
import 'package:flutter/material.dart';
import 'package:edi301/models/family_model.dart';
import 'package:edi301/services/search_api.dart';
import 'package:edi301/services/members_api.dart';
import 'package:edi301/constants/member_types.dart';

class AddAlumnsController {
  BuildContext? context;
  final _searchApi = SearchApi();
  final _membersApi = MembersApi();

  final loading = ValueNotifier<bool>(false);

  // --- Estado que la UI observará ---
  final ValueNotifier<Family?> selectedFamily = ValueNotifier(null);
  final ValueNotifier<List<UserMini>> selectedAlumns = ValueNotifier([]);

  void init(BuildContext context) {
    this.context = context;
  }

  void dispose() {
    loading.dispose();
    selectedFamily.dispose();
    selectedAlumns.dispose();
  }

  // --- Lógica de Búsqueda ---

  /// Busca familias por nombre para el autocompletado.
  Future<List<Family>> searchFamilies(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final result = await _searchApi.searchAll(query);
      // Convertimos FamilyMini a Family para mantener consistencia
      return result.familias
          .map((f) => Family(id: f.id, familyName: f.nombre))
          .toList();
    } catch (e) {
      debugPrint('Error buscando familias: $e');
      return [];
    }
  }

  /// Busca alumnos por matrícula o nombre para el autocompletado.
  Future<List<UserMini>> searchAlumns(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final result = await _searchApi.searchAll(query);
      return result.alumnos;
    } catch (e) {
      debugPrint('Error buscando alumnos: $e');
      return [];
    }
  }

  // --- Lógica de Selección ---

  void selectFamily(Family family) {
    selectedFamily.value = family;
  }

  void clearFamily() {
    selectedFamily.value = null;
  }

  void addAlumn(UserMini alumn) {
    final currentList = selectedAlumns.value;
    // Evitar duplicados
    if (!currentList.any((a) => a.id == alumn.id)) {
      selectedAlumns.value = [...currentList, alumn];
    }
  }

  void removeAlumn(UserMini alumn) {
    final currentList = selectedAlumns.value;
    currentList.removeWhere((a) => a.id == alumn.id);
    selectedAlumns.value = [...currentList];
  }

  // --- Lógica de Guardado ---

  Future<void> saveAssignments() async {
    if (selectedFamily.value == null) {
      _snack('Por favor, selecciona una familia.');
      return;
    }
    if (selectedAlumns.value.isEmpty) {
      _snack('Por favor, añade al menos un alumno.');
      return;
    }

    loading.value = true;
    int successCount = 0;
    final List<String> errors = [];

    for (final alumn in selectedAlumns.value) {
      try {
        await _membersApi.addMember(
          idFamilia: selectedFamily.value!.id!,
          idUsuario: alumn.id,
          tipoMiembro: MemberTypes.hijo, // 'HIJO'
        );
        successCount++;
      } catch (e) {
        errors.add(
          '${alumn.nombre}: ${e.toString().replaceFirst("Exception: ", "")}',
        );
      }
    }

    loading.value = false;

    if (context!.mounted) {
      if (errors.isEmpty) {
        _snack(
          '$successCount alumno(s) asignado(s) con éxito.',
          isError: false,
        );
        Navigator.pop(context!, true);
      } else {
        _snack(
          'Se asignaron $successCount alumno(s). Errores: ${errors.join(", ")}',
        );
      }
    }
  }

  void _snack(String msg, {bool isError = true}) {
    if (context?.mounted ?? false) {
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }
  }
}
