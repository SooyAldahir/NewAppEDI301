import 'package:flutter/material.dart';
import 'package:edi301/src/pages/Admin/get_family/family_model.dart' as fm;
// Si la lista vive en otro controller:
import 'package:edi301/src/pages/Admin/add_family/add_family_controller.dart';

class GetFamiliyController {
  BuildContext? context;

  final TextEditingController searchCtrl = TextEditingController();
  final ValueNotifier<List<fm.Family>> results = ValueNotifier<List<fm.Family>>(
    [],
  );

  Future<void> init(BuildContext context) async {
    this.context = context;
    results.value = List<fm.Family>.from(AddFamilyController.familyList);
    searchCtrl.addListener(_doFilter);
  }

  List<fm.Family> get allFamilies =>
      AddFamilyController.familyList.cast<fm.Family>();

  void _doFilter() {
    final q = searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) {
      results.value = List<fm.Family>.from(allFamilies);
    } else {
      results.value = allFamilies
          .where((f) => f.familyName.toLowerCase().contains(q))
          .toList();
    }
  }

  void goToGetFamilyPage() => Navigator.pushNamed(context!, 'get_family');
  void goToAdminPage() => Navigator.pop(context!);

  void dispose() {
    searchCtrl.dispose();
    results.dispose();
  }
}
