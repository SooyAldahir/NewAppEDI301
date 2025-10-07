import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(children: [_textFieldSearch()]),
      ),
    );
  }

  Widget _textFieldSearch() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
      child: TextFormField(
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          hintText: 'Ingrese una matricula o # de empleado',
          filled: true,
          fillColor: Colors.white, // Fondo blanco
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              color: Color.fromRGBO(245, 188, 6, 1), // Borde amarillo
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              color: Color.fromRGBO(
                245,
                188,
                6,
                1,
              ), // Borde amarillo cuando no está enfocado
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              color: Color.fromRGBO(
                245,
                188,
                6,
                1,
              ), // Borde amarillo cuando está enfocado
              width: 2, // Ancho del borde cuando está enfocado
            ),
          ),
          contentPadding: const EdgeInsets.all(15),
          suffixIcon: const Icon(
            Icons.search,
            color: Color.fromRGBO(19, 67, 107, 1),
          ),
        ),
      ),
    );
  }
}
