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

  // Función para guardar el dibujo
  Future<void> _saveDrawing() async {
    try {
      // 1. Extraemos los datos del dibujo en formato PNG
      final byteData = await _drawingController.getImageData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) return;

      // 2. Buscamos la carpeta de documentos de la app
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // 3. Guardamos con el prefijo "onironautica_" exacto que busca tu GalleryScreen
      final filePath = '${directory.path}/onironautica_$timestamp.png';

      final file = File(filePath);
      await file.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );

      if (mounted) {
        // 4. Mostramos éxito y regresamos a la galería mandando un "true"
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dibujo guardado con éxito')),
        );
        Navigator.pop(
          context,
          true,
        ); // Esto activa el _loadDrawings() de tu galería
      }
    } catch (e) {
      debugPrint("Error al guardar: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _drawingController.setStyle(color: Colors.blue);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Dibujo'),
        actions: [
          // Agregamos el botón de guardado en la esquina superior derecha
          IconButton(icon: const Icon(Icons.save), onPressed: _saveDrawing),
        ],
      ),
      body: Column(
        children: [
          // Drawing Board
          Expanded(
            child: DrawingBoard(
              controller: _drawingController,
              background: Container(
                width: size.width,
                height:
                    size.height *
                    0.6, // Tamaño fijo que ya comprobamos que funciona
                color: Colors.white,
              ),
            ),
          ),

          // Action Bar (color, undo, redo, clear...)
          DrawingBar(
            controller: _drawingController,
            tools: [
              DefaultActionItem.slider(),
              // DefaultActionItem.color(),
              DefaultActionItem.undo(),
              DefaultActionItem.redo(),
              DefaultActionItem.turn(),
              DefaultActionItem.clear(),
            ],
          ),

          // Tool Bar (pincel, borrador, formas...)
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
