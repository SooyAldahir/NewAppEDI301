import 'package:flutter/material.dart';
import 'package:edi301/Register/register_controller.dart';
import 'package:flutter/scheduler.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final RegisterController _controller = RegisterController();
  int _currentStep = 0; // Controla el paso actual
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(19, 67, 107, 1),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 40, right: 40, top: 100),
                child: Image(
                  image: AssetImage('assets/img/logo_edi.png'),
                  width: 225,
                  height: 225,
                ),
              ),
              if (_currentStep == 0) _textFieldEmail(),
              if (_currentStep == 1) _textFieldVerificationCode(),
              if (_currentStep == 2) _textFieldPassword(),
              if (_currentStep == 2) _textFieldConfirmPassword(),
              _buttonAction(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textFieldEmail() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color.fromRGBO(245, 188, 6, 1), width: 2),
        ),
      ),
      child: TextField(
        controller: _emailController,
        decoration: const InputDecoration(
          hintText: 'Ingrese su correo institucional',
          hintStyle: TextStyle(color: Colors.white),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(15),
          prefixIcon: Icon(Icons.person, color: Colors.white),
        ),
      ),
    );
  }

  Widget _textFieldVerificationCode() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color.fromRGBO(245, 188, 6, 1), width: 2),
        ),
      ),
      child: TextField(
        controller: _verificationCodeController,
        decoration: const InputDecoration(
          hintText: 'Ingrese el código de verificación',
          hintStyle: TextStyle(color: Colors.white),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(15),
          prefixIcon: Icon(Icons.verified, color: Colors.white),
        ),
      ),
    );
  }

  Widget _textFieldPassword() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color.fromRGBO(245, 188, 6, 1), width: 2),
        ),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: true,
        decoration: const InputDecoration(
          hintText: 'Ingrese su contraseña',
          hintStyle: TextStyle(color: Colors.white),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(15),
          prefixIcon: Icon(Icons.key, color: Colors.white),
        ),
      ),
    );
  }

  Widget _textFieldConfirmPassword() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color.fromRGBO(245, 188, 6, 1), width: 2),
        ),
      ),
      child: TextField(
        controller: _confirmPasswordController,
        obscureText: true,
        decoration: const InputDecoration(
          hintText: 'Confirme su contraseña',
          hintStyle: TextStyle(color: Colors.white),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(15),
          prefixIcon: Icon(Icons.key, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buttonAction() {
    String buttonText;
    VoidCallback onPressed;

    switch (_currentStep) {
      case 0:
        buttonText = 'Verificar correo';
        onPressed = _verifyEmail;
        break;
      case 1:
        buttonText = 'Verificar';
        onPressed = _verifyCode;
        break;
      case 2:
        buttonText = 'Registrarme';
        onPressed = _register;
        break;
      default:
        buttonText = 'Continuar';
        onPressed = () {};
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: const Color.fromRGBO(245, 188, 6, 1),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  void _verifyEmail() {
    setState(() {
      _currentStep = 1;
    });
  }

  void _verifyCode() {
    setState(() {
      _currentStep = 2;
    });
  }

  void _register() {
    _controller.goToLoginPage();
  }
}
