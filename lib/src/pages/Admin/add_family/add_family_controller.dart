import 'package:edi301/src/pages/Admin/get_family/family_model.dart';
import 'package:flutter/material.dart';

class AddFamilyController {
  static final List<Family> familyList = []; // 🔹 lista compartida en memoria
  late BuildContext context;

  void init(BuildContext context) {
    this.context = context;
  }

  void saveFamily(Family family) {
    familyList.add(family);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Familia guardada correctamente')),
    );
  }

  static bool addStudentsToFamily(String familyName, List<String> students) {
    final idx = familyList.indexWhere(
      (f) => f.familyName.toLowerCase() == familyName.toLowerCase(),
    );
    if (idx == -1) return false;
    familyList[idx].assignedStudents.addAll(students);
    return true;
  }

  void goToAddFamilyPage() {
    Navigator.pushNamed(context, 'add_family');
  }

  void goToAdminPage() {
    Navigator.pop(context);
  }
}
