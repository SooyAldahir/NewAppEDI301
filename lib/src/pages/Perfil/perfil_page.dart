import 'package:flutter/material.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  bool light0 = true;
  bool light1 = false;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          bool isPortrait = orientation == Orientation.portrait;

          return Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isPortrait
                      ? screenWidth *
                            0.8 // 80% del ancho en modo vertical
                      : screenWidth * 0.15, // 60% del ancho en modo horizontal
                  maxHeight: isPortrait
                      ? screenHeight *
                            0.9 // 90% de la altura en modo vertical
                      : screenHeight *
                            0.8, // 80% de la altura en modo horizontal
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 80,
                      backgroundImage: NetworkImage(
                        'https://cdn-icons-png.flaticon.com/512/7141/7141724.png',
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Hola, Aldahir Ballina',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Matrícula:'), Text('221391')],
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Teléfono:'), Text('961 900 1640')],
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Correo:'),
                        Text('aldahir.ballina@ulv.edu.mx'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Residencia:'), Text('Externa')],
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Activar Notificaciones',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Switch(
                              value: light0,
                              activeThumbColor: const Color.fromRGBO(
                                19,
                                67,
                                107,
                                1,
                              ),
                              onChanged: (bool value) {
                                setState(() {
                                  light0 = value;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Modo Oscuro',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Switch(
                              value: light1,
                              activeThumbColor: const Color.fromRGBO(
                                19,
                                67,
                                107,
                                1,
                              ),
                              onChanged: (bool value) {
                                setState(() {
                                  light1 = value;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Mostrar Foto de Perfil',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Switch(
                              value: light0,
                              activeThumbColor: const Color.fromRGBO(
                                19,
                                67,
                                107,
                                1,
                              ),
                              onChanged: (bool value) {
                                setState(() {
                                  light0 = value;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Actualzacion en 2do Plano',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Switch(
                              value: light0,
                              activeThumbColor: const Color.fromRGBO(
                                19,
                                67,
                                107,
                                1,
                              ),
                              onChanged: (bool value) {
                                setState(() {
                                  light0 = value;
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recordar Cumpleaños',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Switch(
                              value: light0,
                              activeThumbColor: const Color.fromRGBO(
                                19,
                                67,
                                107,
                                1,
                              ),
                              onChanged: (bool value) {
                                setState(() {
                                  light0 = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
