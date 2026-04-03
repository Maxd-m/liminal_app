import 'package:flutter/material.dart';
import 'package:liminal_app/components/button_component.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          // Color de fondo base (verde oliva)
          // color: Color(0xFF9E9E68),
          // Descomenta esto si vas a usar el patrón de fondo como imagen
          image: DecorationImage(
            image: AssetImage('assets/bg1.jpg'),
            fit: BoxFit.cover,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // --- Textos de la Cabecera ---
              Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: Column(
                  children: const [
                    Text(
                      'ONIRONAUTICA',
                      style: TextStyle(
                        fontFamily: 'Instrument Serif',
                        fontSize: 42,
                        color: Color(0xFF2E3982), // Azul oscuro
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Soñar es bueno,\ndespertar es necesario',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Instrument Serif',
                        fontSize: 28,
                        height: 1.2,
                        color: Color(0xFFA7E7FF), // Azul claro / cian
                      ),
                    ),
                  ],
                ),
              ),

              // --- Botones Centrales (Morados) ---
              Column(
                children: [
                  CustomButton(
                    text: 'Objetivos',
                    backgroundColor: Color(0xFFD4B8FF),
                    shadowOffset: Offset(0, 8), // Y = 8
                    onTap: () => Navigator.pushNamed(context, "/list"),
                  ),
                  SizedBox(height: 32),
                  CustomButton(
                    text: 'Categorias y actividades',
                    backgroundColor: Color(0xFFD4B8FF),
                    shadowOffset: Offset(0, 8), // Y = 8
                    onTap: () => Navigator.pushNamed(context, "/cruds"),
                  ),
                  SizedBox(height: 32),
                  CustomButton(
                    text: '¿Galería?',
                    backgroundColor: Color(0xFFD4B8FF),
                    shadowOffset: Offset(0, 8), // Y = 8
                    onTap: () => Navigator.pushNamed(context, "/list"),
                  ),
                ],
              ),

              // --- Botón Inferior (Naranja) ---
              Padding(
                padding: EdgeInsets.only(bottom: 60.0),
                // child: CustomButton(
                //   text: 'Lorem ipsum',
                //   backgroundColor: Color(0xFFFFC6A7),
                //   shadowOffset: Offset(0, 4), // Y = 4
                //   onTap: () => Navigator.pushNamed(context, "/list"),
                // ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
