import 'package:flutter/material.dart';
import 'package:edi301/src/pages/Admin/add_family/add_family_controller.dart';
import 'package:edi301/src/pages/Admin/add_alumns/add_alumns_controller.dart';
import 'package:edi301/src/pages/Admin/get_family/get_familiy_controller.dart';
import 'package:flutter/scheduler.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final AddFamilyController _controller = AddFamilyController();
  final AddAlumnsController _alumnsController = AddAlumnsController();
  final GetFamiliyController _getFamiliyController = GetFamiliyController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.init(context);
      _alumnsController.init(context);
      _getFamiliyController.init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CustomButton(
              label: 'Agregar Familia',
              onPressed: _controller.goToAddFamilyPage,
              icon: Icons.add_home,
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CustomButton(
              label: 'Asignar Alumnos',
              onPressed: _alumnsController.goToAddAlumnsPage,
              icon: Icons.person_add,
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CustomButton(
              label: 'Consultar Familias',
              onPressed: _getFamiliyController.goToGetFamilyPage,
              icon: Icons.visibility,
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(245, 188, 6, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Borde redondeado
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ), // Tamaño del botón
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10), // Espacio entre el texto y el icono
          Icon(icon, color: Colors.white, size: 30),
        ],
      ),
    );
  }
}
