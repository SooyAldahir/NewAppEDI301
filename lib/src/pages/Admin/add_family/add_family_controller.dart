// lib/src/pages/Admin/add_family/add_family_controller.dart
import 'package:flutter/material.dart';
import 'package:edi301/services/search_api.dart';
import 'package:edi301/models/family_model.dart';
import 'package:edi301/services/familia_api.dart';
import 'package:edi301/services/members_api.dart';
import 'package:flutter/foundation.dart';

class AddFamilyController {
  // ========= Estado compartido =========
  static final ValueNotifier<List<Family>> familyList =
      ValueNotifier<List<Family>>([]);

  // Campos del form "Agregar familia"
  final ValueNotifier<String> _familyName = ValueNotifier<String>('');
  String get familyName => _familyName.value;
  set familyName(String v) => _familyName.value = v;
  ValueListenable<String> get familyNameListenable => _familyName;

  final ValueNotifier<bool> _internalResidence = ValueNotifier<bool>(true);
  bool get internalResidence => _internalResidence.value;
  set internalResidence(bool v) => _internalResidence.value = v;
  ValueListenable<bool> get internalResidenceListenable => _internalResidence;

  final TextEditingController addressCtrl = TextEditingController();

  // Búsqueda papá/mamá (empleados)
  final TextEditingController fatherCtrl = TextEditingController();
  final TextEditingController motherCtrl = TextEditingController();
  final ValueNotifier<List<UserMini>> fatherResults =
      ValueNotifier<List<UserMini>>([]);
  final ValueNotifier<List<UserMini>> motherResults =
      ValueNotifier<List<UserMini>>([]);
  UserMini? _pickedFather;
  UserMini? _pickedMother;

  // Hijos sanguíneos (alumnos)
  final TextEditingController searchChildCtrl = TextEditingController();
  final ValueNotifier<List<UserMini>> childResults =
      ValueNotifier<List<UserMini>>([]);
  final ValueNotifier<List<UserMini>> children = ValueNotifier<List<UserMini>>(
    [],
  );

  final ValueNotifier<bool> _loading = ValueNotifier<bool>(false);
  ValueListenable<bool> get loading => _loading;

  final _searchApi = SearchApi();
  final _familiaApi = FamiliaApi();
  final _membersApi = MembersApi();

  void dispose() {
    addressCtrl.dispose();
    fatherCtrl.dispose();
    motherCtrl.dispose();
    searchChildCtrl.dispose();
    fatherResults.dispose();
    motherResults.dispose();
    childResults.dispose();
    children.dispose();
    _familyName.dispose();
    _internalResidence.dispose();
    _loading.dispose();
  }

  // Genera nombre automático: "Familia <apPatPadre> <apPatMadre>"
  void recomputeFamilyName() {
    final f = _pickedFather?.apellido.trim().split(' ').first ?? '';
    final m = _pickedMother?.apellido.trim().split(' ').first ?? '';
    final base = [f, m].where((e) => e.isNotEmpty).join(' ');
    _familyName.value = base.isEmpty ? '' : 'Familia $base';
  }

  // ========= Búsqueda empleados (empleados + externos) =========
  Future<void> searchEmployee(String q, {required bool isFather}) async {
    q = q.trim();
    final target = isFather ? fatherResults : motherResults;

    if (q.isEmpty) {
      target.value = [];
      return;
    }

    final res = await _searchApi.searchAll(q);

    // Combina empleados + externos
    final merged = <int, UserMini>{};
    for (final u in res.empleados) merged[u.id] = u;
    for (final u in res.externos) merged[u.id] = u; // 👈 suma externos
    target.value = merged.values.toList();
  }

  void pickFather(UserMini u) => _pickParent(u, true);
  void pickMother(UserMini u) => _pickParent(u, false);

  void _pickParent(UserMini u, bool isFather) {
    if (isFather) {
      _pickedFather = u;
      fatherCtrl.text = '${u.nombre} ${u.apellido}'.trim();
      fatherResults.value = [];
    } else {
      _pickedMother = u;
      motherCtrl.text = '${u.nombre} ${u.apellido}'.trim();
      motherResults.value = [];
    }
    recomputeFamilyName();
  }

  // ========= Búsqueda alumnos =========
  Future<void> searchChildByText(String q) async {
    q = q.trim();
    if (q.isEmpty) {
      childResults.value = [];
      return;
    }
    final res = await _searchApi.searchAll(q);
    childResults.value = res.alumnos;
  }

  void addChild(UserMini u) {
    final list = [...children.value];
    if (!list.any((x) => x.id == u.id)) {
      list.add(u);
      children.value = list;
    }
  }

  void removeChild(int index) {
    final list = [...children.value];
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      children.value = list;
    }
  }

  // ========= Guardar familia =========
  Future<void> save(BuildContext context) async {
    _loading.value = true;
    try {
      // 1) Crear familia
      final created = await _familiaApi.createFamily(
        nombreFamilia: _familyName.value.trim(),
        residencia: _internalResidence.value ? 'INTERNA' : 'EXTERNA',
        direccion: _internalResidence.value
            ? null
            : (addressCtrl.text.trim().isEmpty
                  ? null
                  : addressCtrl.text.trim()),
      );

      // 2) Registrar miembros (usando id_usuario directo)
      if (_pickedFather != null) {
        await _membersApi.addMember(
          idFamilia: created.id!,
          idUsuario: _pickedFather!.id,
          tipoMiembro: 'PADRE',
        );
      }
      if (_pickedMother != null) {
        await _membersApi.addMember(
          idFamilia: created.id!,
          idUsuario: _pickedMother!.id,
          tipoMiembro: 'MADRE',
        );
      }
      for (final kid in children.value) {
        await _membersApi.addMember(
          idFamilia: created.id!,
          idUsuario: kid.id,
          tipoMiembro: 'HIJO',
        );
      }

      // 3) Refresca lista local
      final list = [...familyList.value]..add(created);
      familyList.value = list;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Familia creada con éxito')),
        );
      }

      // Limpia
      _pickedFather = null;
      _pickedMother = null;
      fatherCtrl.clear();
      motherCtrl.clear();
      addressCtrl.clear();
      children.value = [];
      _familyName.value = '';
      _internalResidence.value = true;
      fatherResults.value = [];
      motherResults.value = [];
      childResults.value = [];
    } finally {
      _loading.value = false;
    }
  }

  // ========= Usado por otras pantallas =========
  static bool addStudentsToFamily(String famName, List<String> students) {
    final idx = familyList.value.indexWhere(
      (f) => f.familyName.toLowerCase().trim() == famName.toLowerCase().trim(),
    );
    if (idx < 0) return false;
    final f = familyList.value[idx];
    final updated = f.copyWith(
      assignedStudents: [...f.assignedStudents, ...students],
    );
    final list = [...familyList.value];
    list[idx] = updated;
    familyList.value = list;
    return true;
  }

  static void removeHouseholdChild(int index, String child) {
    if (index < 0 || index >= familyList.value.length) return;
    final f = familyList.value[index];
    final list = [...f.householdChildren]..remove(child);
    final updated = f.copyWith(householdChildren: list);
    final all = [...familyList.value];
    all[index] = updated;
    familyList.value = all;
  }

  static void removeAssignedStudent(int index, String student) {
    if (index < 0 || index >= familyList.value.length) return;
    final f = familyList.value[index];
    final list = [...f.assignedStudents]..remove(student);
    final updated = f.copyWith(assignedStudents: list);
    final all = [...familyList.value];
    all[index] = updated;
    familyList.value = all;
  }
}
