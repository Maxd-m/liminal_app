// Widget personalizado para aplicar sombras y estilos exactos
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Offset shadowOffset;
  final VoidCallback onTap; // 1. Agregamos esta línea

  const CustomButton({
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
