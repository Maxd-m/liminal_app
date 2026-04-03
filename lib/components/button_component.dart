// Widget personalizado para aplicar sombras y estilos exactos
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Offset shadowOffset;
  final VoidCallback onTap;

  const CustomButton({
    Key? key,
    required this.text,
    required this.backgroundColor,
    required this.shadowOffset,
    required this.onTap,
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
          onTap: onTap,
          child: Center(
            // 1. Agregamos un Padding para que el texto respire y no toque el borde del botón
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              // 2. Usamos FittedBox para escalar el texto hacia abajo si excede el espacio
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  style: const TextStyle(
                    fontFamily: 'Instrument Serif',
                    fontSize: 22, // Este actuará como el tamaño máximo
                    color: Color(0xFF5D6151),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
