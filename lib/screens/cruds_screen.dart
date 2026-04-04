import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:liminal_app/database/objetivos_db.dart'; // Ajusta la ruta a tu DB
import 'package:liminal_app/screens/dialogs/category_dialog.dart';
import 'package:liminal_app/screens/dialogs/activity_dialog.dart';

class CrudsScreen extends StatefulWidget {
  const CrudsScreen({Key? key}) : super(key: key);

  @override
  State<CrudsScreen> createState() => _CrudsScreenState();
}

class _CrudsScreenState extends State<CrudsScreen> {
  final ObjetivosDB _databaseHelper = ObjetivosDB();

  // Estado principal: determina qué tabla estamos viendo
  bool _isViewingActivities = true;

  // Listas de datos
  List<Map<String, dynamic>> _currentItems = [];
  List<Map<String, dynamic>> _categories =
      []; // Necesaria para el modal de actividades

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadCategoriesForModal();
  }

  // Carga los datos dependiendo de la vista actual
  Future<void> _loadData() async {
    List<Map<String, dynamic>> data = [];
    if (_isViewingActivities) {
      // TODO: Reemplaza con tu método real de la DB que traiga las actividades
      // Idealmente, que haga un JOIN para traer también el nombre de la categoría
      data = await _databaseHelper.getAllActivities();
    } else {
      // TODO: Reemplaza con tu método real de la DB para traer categorías
      data = await _databaseHelper.getAllCategories();
    }

    setState(() {
      _currentItems = data;
    });
  }

  Future<void> _loadCategoriesForModal() async {
    final categories = await _databaseHelper.getAllCategories();
    setState(() {
      _categories = categories;
    });
  }

  // --- MÉTODOS DE ELIMINACIÓN ---
  void _deleteItem(int id) async {
    if (_isViewingActivities) {
      // TODO:
      await _databaseHelper.deleteActivity(id);
    } else {
      // TODO:
      await _databaseHelper.deleteCategory(id);
    }
    _loadData(); // Recargar después de borrar
  }

  // --- MODALES (INSERTS) ---
  void _showAddModal() {
    if (_isViewingActivities) {
      _showAddActivityModal();
    } else {
      _showAddCategoryModal();
    }
  }

  void _showAddCategoryModal() async {
    final changed = await showDialog(
      context: context,
      builder: (_) => CategoryDialog(databaseHelper: _databaseHelper),
    );

    if (changed == true) {
      _loadData();
      _loadCategoriesForModal();
    }
  }

  void _showAddActivityModal() async {
    final changed = await showDialog(
      context: context,
      builder: (_) => ActivityDialog(
        databaseHelper: _databaseHelper,
        categories: _categories,
      ),
    );

    if (changed == true) {
      _loadData();
    }
  }

  void _showCategoryModal([Map<String, dynamic>? categoryToEdit]) async {
    final changed = await showDialog(
      context: context,
      builder: (_) => CategoryDialog(
        databaseHelper: _databaseHelper,
        categoryToEdit: categoryToEdit,
      ),
    );

    if (changed == true) {
      _loadData();
      _loadCategoriesForModal();
    }
  }

  void _showActivityModal([Map<String, dynamic>? activityToEdit]) async {
    final changed = await showDialog(
      context: context,
      builder: (_) => ActivityDialog(
        databaseHelper: _databaseHelper,
        categories: _categories,
        activityToEdit: activityToEdit,
      ),
    );

    if (changed == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(
      fontFamily: 'Instrument Serif',
      fontSize: 38,
      color: Color(0xFF527482), // Azul/Gris oscuro del titulo
    );

    return Scaffold(
      body: Container(
        // TODO: Agrega tu imagen de fondo real aquí
        decoration: const BoxDecoration(
          color: Color(
            0xFF2E3324,
          ), // Un color de fondo por si no carga la imagen
          image: DecorationImage(
            image: AssetImage('assets/bg2.jpg'), // Cambia a la ruta de tu fondo
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // --- CABECERA ---
              // const Text('ONIRONAUTICA', style: titleStyle),
              AnimatedOpacity(
                opacity: 1.0,
                // : 0.0, // Si es true, opacidad 1 (visible), si no 0 (invisible)
                duration: const Duration(milliseconds: 2000),
                child: AnimatedTextKit(
                  repeatForever: true,
                  animatedTexts: [
                    ColorizeAnimatedText(
                      'Onironautica',
                      textStyle: TextStyle(
                        fontFamily: 'Instrument Serif',
                        fontSize: 42,
                        color: Color(0xFF2E3982),
                      ),
                      colors: [
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
              Text(
                _isViewingActivities ? 'Actividades' : 'Categorias',
                style: titleStyle.copyWith(
                  fontSize: 32,
                  color: const Color(0xFF6B8A98),
                ),
              ),

              const SizedBox(height: 20),

              // --- BOTONES SUPERIORES ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Botón Ir a Inicio (Fijo)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD3ACFF), // Morado
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Ir a Inicio',
                        style: TextStyle(
                          color: Colors.black87,
                          fontFamily: 'Instrument Serif',
                          fontSize: 18,
                        ),
                      ),
                    ),

                    // Botón Alternador (Cambia según el estado)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFF6CDB4,
                        ), // Naranja claro
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _isViewingActivities = !_isViewingActivities;
                        });
                        _loadData(); // Recargamos la lista con la nueva vista
                      },
                      child: Text(
                        _isViewingActivities ? 'Categorias' : 'Actividades',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontFamily: 'Instrument Serif',
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- LISTA DE ITEMS ---
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  itemCount: _currentItems.length,
                  itemBuilder: (context, index) {
                    final item = _currentItems[index];

                    // Asumiendo nombres de columnas estándar (ajusta según tu DB)
                    final title = _isViewingActivities
                        ? item['actividad']
                        : item['categoria'];
                    final subtitle = _isViewingActivities
                        ? item['nombre_categoria']
                        : null;
                    final id = item['id'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFFD6D3CD,
                        ).withOpacity(0.9), // Fondo de las tarjetas
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title ?? 'Sin título',
                            style: const TextStyle(
                              fontFamily: 'Instrument Serif',
                              fontSize: 24,
                              color: Color(0xFF2E3A59),
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontFamily: 'Instrument Serif',
                                fontSize: 16,
                                color: Color(0xFF527482),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Botón Editar
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFAEE2FF),
                                  minimumSize: const Size(80, 30),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () {
                                  if (_isViewingActivities) {
                                    _showActivityModal(item);
                                  } else {
                                    _showCategoryModal(item);
                                  }
                                },
                                child: const Text(
                                  'Editar',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Botón Eliminar
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(
                                    0xFFC96A6A,
                                  ), // Rojo coral
                                  minimumSize: const Size(80, 30),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () => _deleteItem(id),
                                child: const Text(
                                  'Eliminar',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
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
      ),

      // --- BOTÓN FLOTANTE (NUEVO) ---
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddModal,
        backgroundColor: const Color(0xFFFCF9EA), // Amarillo pálido/blanco
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Nuevo',
              style: TextStyle(
                fontSize: 10,
                color: Colors.black54,
                fontFamily: 'Instrument Serif',
              ),
            ),
            Icon(Icons.add, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
