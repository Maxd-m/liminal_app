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

  // Función para leer las imágenes guardadas
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

  // NUEVA FUNCIÓN: Eliminar archivo físico y recargar la galería
  Future<void> _deleteDrawing(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        if (mounted) {
          Navigator.pop(context); // Cierra el modal
          _loadDrawings(); // Recarga la lista de imágenes
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dibujo eliminado correctamente')),
          );
        }
      }
    } catch (e) {
      debugPrint("Error al eliminar: $e");
    }
  }

  // NUEVA FUNCIÓN: Mostrar el modal con la imagen y los botones
  void _showImageModal(File file) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors
              .transparent, // Fondo transparente para que destaque la imagen
          insetPadding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Se adapta al tamaño de su contenido
            children: [
              // Imagen ampliada
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  color:
                      Colors.white, // Por si el dibujo tiene fondo transparente
                  child: Image.file(file, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 20),

              // Botones de acción usando tu CustomButton
              // Usamos un Wrap para evitar errores de espacio en pantallas pequeñas
              Wrap(
                spacing: 15, // Espacio horizontal entre botones
                runSpacing: 10, // Espacio vertical si se amontonan
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
                    backgroundColor: const Color(
                      0xFFFFA1A1,
                    ), // Un rojo suave para la acción de borrar
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Imagen de fondo
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg2.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
              ),
            ),
          ),

          // 2. Contenido principal
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

                // Botón "Ir a Inicio"
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

                // 3. Cuadrícula de imágenes (GridView)
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
                                childAspectRatio: 1,
                              ),
                          itemCount: _savedDrawings.length,
                          itemBuilder: (context, index) {
                            final file = File(_savedDrawings[index].path);

                            // AQUI ESTÁ EL CAMBIO: Envolvemos el Container en un GestureDetector
                            return GestureDetector(
                              onTap: () => _showImageModal(file),
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
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),

      // 4. Floating Action Button "Nuevo +"
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
