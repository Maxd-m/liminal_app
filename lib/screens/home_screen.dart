import 'package:flutter/material.dart';

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
                        color: Color(0xFF2C3989), // Azul oscuro
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
                        color: Color(0xFF7CB8C7), // Azul claro / cian
                      ),
                    ),
                  ],
                ),
              ),

              // --- Botones Centrales (Morados) ---
              Column(
                children: [
                  _CustomButton(
                    text: 'Actividades',
                    backgroundColor: Color(0xFFD3ACFF),
                    shadowOffset: Offset(0, 8), // Y = 8
                    onTap: () => Navigator.pushNamed(context, "/list"),
                  ),
                  SizedBox(height: 32),
                  _CustomButton(
                    text: 'Lorem ipsum',
                    backgroundColor: Color(0xFFD3ACFF),
                    shadowOffset: Offset(0, 8), // Y = 8
                    onTap: () => Navigator.pushNamed(context, "/list"),
                  ),
                  SizedBox(height: 32),
                  _CustomButton(
                    text: 'Lorem ipsum',
                    backgroundColor: Color(0xFFD3ACFF),
                    shadowOffset: Offset(0, 8), // Y = 8
                    onTap: () => Navigator.pushNamed(context, "/list"),
                  ),
                ],
              ),

              // --- Botón Inferior (Naranja) ---
              Padding(
                padding: EdgeInsets.only(bottom: 60.0),
                child: _CustomButton(
                  text: 'Lorem ipsum',
                  backgroundColor: Color(0xFFF9C2A4),
                  shadowOffset: Offset(0, 4), // Y = 4
                  onTap: () => Navigator.pushNamed(context, "/list"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget personalizado para aplicar sombras y estilos exactos
class _CustomButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Offset shadowOffset;
  final VoidCallback onTap; // 1. Agregamos esta línea

  const _CustomButton({
    Key? key,
    required this.text,
    required this.backgroundColor,
    required this.shadowOffset,
    required this.onTap, // 2. Lo pedimos en el constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 154,
      height: 58,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: shadowOffset,
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap, // 3. Le pasamos la acción al InkWell
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Instrument Serif',
                fontSize: 22,
                color: Color(0xFF5D6151),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
