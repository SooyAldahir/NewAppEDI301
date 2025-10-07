import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginController {
  BuildContext? context;

  Future? init(BuildContext context) {
    this.context = context;
    return null;
  }

  void goToRegisterPage() {
    Navigator.pushNamed(context!, 'register');
  }

  void goToHomePage() {
    Navigator.pushNamed(context!, 'home');
  }
}
