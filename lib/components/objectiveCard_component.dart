// =====================================================================
// WIDGET REUTILIZABLE DE LA TARJETA
// =====================================================================
import 'package:flutter/material.dart';
import 'package:liminal_app/components/miniButton_component.dart';

class ObjectiveCard extends StatelessWidget {
  final String titulo;
  final String fecha;
  final String estado;
  final VoidCallback onVerActividades;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const ObjectiveCard({
    Key? key,
    required this.titulo,
    required this.fecha,
    required this.estado,
    required this.onVerActividades,
    required this.onEditar,
    required this.onEliminar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75), // Fondo semi-transparente
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontFamily: 'Instrument Serif',
                  fontSize: 24,
                  color: Color(0xFF2C3989),
                ),
              ),
              _buildEstadoText(), // Aquí se aplica el ShaderMask
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Fecha límite: $fecha',
            style: const TextStyle(
              fontFamily: 'Instrument Serif',
              fontSize: 16,
              color: Color(0xFF2C3989),
            ),
          ),
          const SizedBox(height: 16),
          // Mini Botones de Acción
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MiniButton(
                text: 'Ver actividades',
                color: const Color(0xFFF9C2A4), // Naranja
                onTap: onVerActividades,
              ),
              MiniButton(
                text: 'Editar',
                color: const Color(0xFFA4DDF9), // Azul claro
                onTap: onEditar,
              ),
              MiniButton(
                text: 'Eliminar',
                color: const Color(0xFFD07A7A), // Rojo pálido
                onTap: onEliminar,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Método que genera el texto del estado con ShaderMask
  Widget _buildEstadoText() {
    List<Color> gradientColors;

    // Asignación de colores según el estado
    switch (estado.toLowerCase()) {
      case 'vencida':
        gradientColors = [Colors.red, Colors.redAccent.shade700];
        break;
      case 'completada':
        gradientColors = [Colors.blue, Colors.blueAccent.shade700];
        break;
      case 'en tiempo':
      default:
        gradientColors = [const Color(0xFF2C3989), const Color(0xFF7CB8C7)];
        break;
    }

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: Text(
        estado,
        style: const TextStyle(
          fontFamily: 'Instrument Serif',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          // El color debe ser blanco para que el ShaderMask se pinte encima
          color: Colors.white,
        ),
      ),
    );
  }
}
