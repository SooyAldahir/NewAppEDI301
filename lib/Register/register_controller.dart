import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RegisterController {
  BuildContext? context;

  Future? init(BuildContext context) {
    this.context = context;
    return null;
  }

  void goToLoginPage() {
    Navigator.pushNamed(context!, 'login');
  }
}
