import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:liminal_app/components/button_component.dart';
import 'package:path_provider/path_provider.dart';
import 'package:liminal_app/screens/drawing_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<FileSystemEntity> _savedDrawings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDrawings();
  }

  Future<void> _loadDrawings() async {
    setState(() => _isLoading = true);
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync().where((item) {
        return item.path.endsWith('.png') &&
            item.path.contains('onironautica_');
      }).toList();

      files.sort(
        (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
      );

      setState(() {
        _savedDrawings = files;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error cargando imágenes: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteDrawing(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        if (mounted) {
          Navigator.pop(context);
          _loadDrawings();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dibujo eliminado correctamente')),
          );
        }
      }
    } catch (e) {
      debugPrint("Error al eliminar: $e");
    }
  }

  void _showImageModal(File file) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  color: Colors.white,
                  child: Image.file(file, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 15,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  CustomButton(
                    text: 'Cerrar',
                    backgroundColor: const Color(0xFFF4F5DB),
                    shadowOffset: const Offset(0, 4),
                    onTap: () => Navigator.pop(context),
                  ),
                  CustomButton(
                    text: 'Eliminar',
                    backgroundColor: const Color(0xFFFFA1A1),
                    shadowOffset: const Offset(0, 4),
                    onTap: () => _deleteDrawing(file),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // NUEVA FUNCIÓN: Extrae el título del nombre del archivo
  String _extractTitleFromFile(File file) {
    String fileName = file.path
        .split('/')
        .last; // Ej: onironautica_Mi-Titulo_123456.png

    if (fileName.startsWith('onironautica_')) {
      // Quitamos el prefijo
      String withoutPrefix = fileName.replaceFirst('onironautica_', '');
      // Separamos por el guion bajo "_" para aislar el título del timestamp
      List<String> parts = withoutPrefix.split('_');

      if (parts.isNotEmpty) {
        // El primer elemento es nuestro título, y devolvemos los espacios en lugar de guiones
        return parts[0].replaceAll('-', ' ');
      }
    }
    return 'Sin título';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg2.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 2000),
                  child: AnimatedTextKit(
                    repeatForever: true,
                    animatedTexts: [
                      ColorizeAnimatedText(
                        'Onironautica',
                        textStyle: const TextStyle(
                          fontFamily: 'Instrument Serif',
                          fontSize: 42,
                          color: Color(0xFF2E3982),
                        ),
                        colors: const [
                          Color(0xFF2E3982),
                          Color(0xFFD4B8FF),
                          Color.fromARGB(255, 247, 233, 153),
                        ],
                        speed: const Duration(milliseconds: 2000),
                      ),
                    ],
                    isRepeatingAnimation: true,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Galería',
                  style: TextStyle(
                    fontFamily: 'Instrument Serif',
                    fontSize: 32,
                    color: Color(0xFF9EAA78),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: CustomButton(
                      text: 'Ir a Inicio',
                      backgroundColor: const Color(0xFFD3ACFF),
                      shadowOffset: const Offset(0, 4),
                      onTap: () => Navigator.pushNamed(context, "/home"),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _savedDrawings.isEmpty
                      ? const Center(
                          child: Text(
                            "No hay dibujos aún",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                                // Cambiamos un poco el aspect ratio para que quepa el texto
                                childAspectRatio: 0.85,
                              ),
                          itemCount: _savedDrawings.length,
                          itemBuilder: (context, index) {
                            final file = File(_savedDrawings[index].path);
                            final title = _extractTitleFromFile(
                              file,
                            ); // Extraemos el título

                            return GestureDetector(
                              onTap: () => _showImageModal(file),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // El texto del título arriba de la imagen
                                  Text(
                                    title,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  // La imagen ocupando el resto del espacio
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(5),
                                        image: DecorationImage(
                                          image: FileImage(file),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DrawingScreen()),
          );
          if (result == true) {
            _loadDrawings();
          }
        },
        backgroundColor: const Color(0xFFF4F5DB),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Nuevo',
              style: TextStyle(color: Colors.black87, fontSize: 10),
            ),
            Icon(Icons.add, color: Colors.black87, size: 20),
          ],
        ),
      ),
    );
  }
}
