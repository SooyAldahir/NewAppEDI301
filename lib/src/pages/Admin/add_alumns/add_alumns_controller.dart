import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddAlumnsController {
  BuildContext? context;

  Future? init(BuildContext context) {
    this.context = context;
    return null;
  }

  void goToAddAlumnsPage() {
    Navigator.pushNamed(context!, 'add_alumns');
  }

  void goToAdminPage() {
    Navigator.pop(context!);
  }
}
