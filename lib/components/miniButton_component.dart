// Sub-componente privado solo para los botones pequeños de la tarjeta
import 'package:flutter/material.dart';

class MiniButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;

  const MiniButton({
    required this.text,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Instrument Serif',
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
