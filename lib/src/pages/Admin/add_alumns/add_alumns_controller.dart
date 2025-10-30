import 'package:edi301/constants/member_types.dart';
import 'package:flutter/material.dart';
import 'package:edi301/services/search_api.dart';
import 'package:edi301/services/members_api.dart';

class AddAlumnsController {
  BuildContext? context;

  final ValueNotifier<bool> loading = ValueNotifier<bool>(false);

  final _searchApi = SearchApi();
  final _membersApi = MembersApi();

  Future<void> init(BuildContext context) async {
    this.context = context;
  }

  void dispose() {
    loading.dispose();
  }

  /// Resultado del proceso para mostrar feedback
  Future<AddResult> addAlumnsToFamily({
    required int familyId,
    required List<String> matriculas,
  }) async {
    loading.value = true;

    final added = <String>[];
    final notFound = <String>[];
    final errors = <String>[];

    try {
      for (final m in matriculas) {
        final term = m.trim();
        if (term.isEmpty) continue;

        // 1) Buscar alumno por matrícula
        final res = await _searchApi.searchAll(term);
        final match = res.alumnos.firstWhere(
          (u) => (u.matricula?.toString() ?? '') == term,
          orElse: () => null as dynamic,
        );

        if (match == null) {
          notFound.add(term);
          continue;
        }

        try {
          // 2) Registrar como miembro tipo HijoSanguineo
          await _membersApi.addMember(
            idFamilia: familyId,
            idUsuario: match.id,
            tipoMiembro: MemberTypes.hijo, // << HIJO
          );
          added.add(term);
        } catch (e) {
          errors.add('$term (${e.toString()})');
        }
      }
    } finally {
      loading.value = false;
    }

    return AddResult(added: added, notFound: notFound, errors: errors);
  }

  void goToAddAlumnsPage() {
    Navigator.pushNamed(context!, 'add_alumns');
  }

  void goToAdminPage() {
    Navigator.pop(context!);
  }
}

class AddResult {
  final List<String> added;
  final List<String> notFound;
  final List<String> errors;

  AddResult({
    required this.added,
    required this.notFound,
    required this.errors,
  });
}
