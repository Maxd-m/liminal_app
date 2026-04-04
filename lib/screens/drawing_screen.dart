import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:path_provider/path_provider.dart';

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({Key? key}) : super(key: key);

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  final DrawingController _drawingController = DrawingController();

  @override
  void dispose() {
    _drawingController.dispose();
    super.dispose();
  }

  // NUEVA FUNCIÓN: Muestra un modal para pedir el título
  Future<void> _showSaveDialog() async {
    String title = '';
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Guardar Dibujo',
            style: TextStyle(fontFamily: 'Instrument Serif', fontSize: 28),
          ),
          content: TextField(
            decoration: const InputDecoration(
              hintText: 'Ingresa un título...',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => title = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Si el usuario no escribe nada, le ponemos "Sin titulo"
                if (title.trim().isEmpty) {
                  title = 'Sin titulo';
                }
                _saveDrawing(title);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4B8FF),
              ),
              child: const Text(
                'Guardar',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ],
        );
      },
    );
  }

  // Función modificada para recibir el título
  Future<void> _saveDrawing(String title) async {
    try {
      final byteData = await _drawingController.getImageData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // Limpiamos el título para que no tenga caracteres raros que rompan el archivo
      // y cambiamos los espacios por guiones medios
      String safeTitle = title
          .replaceAll(RegExp(r'[^a-zA-Z0-9\sáéíóúÁÉÍÓÚñÑ]'), '')
          .replaceAll(' ', '-');

      // Guardamos con el formato: onironautica_TÍTULO_TIMESTAMP.png
      final filePath =
          '${directory.path}/onironautica_${safeTitle}_$timestamp.png';

      final file = File(filePath);
      await file.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dibujo guardado con éxito')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Error al guardar: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _drawingController.setStyle(color: Color.fromARGB(255, 82, 99, 87));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Dibujo'),
        actions: [
          // Cambiamos el onPressed para que llame al Dialog en lugar de guardar directo
          IconButton(icon: const Icon(Icons.save), onPressed: _showSaveDialog),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: DrawingBoard(
              controller: _drawingController,
              background: Container(
                width: size.width,
                height: size.height * 0.6,
                color: Color.fromARGB(200, 217, 217, 217),
              ),
            ),
          ),
          DrawingBar(
            controller: _drawingController,
            tools: [
              DefaultActionItem.slider(),
              DefaultActionItem.undo(),
              DefaultActionItem.redo(),
              DefaultActionItem.turn(),
              DefaultActionItem.clear(),
            ],
          ),
          DrawingBar(
            controller: _drawingController,
            tools: [
              DefaultToolItem.pen(),
              DefaultToolItem.brush(),
              DefaultToolItem.rectangle(),
              DefaultToolItem.circle(),
              DefaultToolItem.straightLine(),
              DefaultToolItem.eraser(),
            ],
          ),
        ],
      ),
    );
  }
}
