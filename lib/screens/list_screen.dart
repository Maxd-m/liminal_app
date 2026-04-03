import 'package:flutter/material.dart';
import 'package:liminal_app/components/button_component.dart';
import 'package:liminal_app/components/objectiveCard_component.dart';
import 'package:liminal_app/utils/addObjectiveModalContent_component.dart'; // Importa el contenido del modal (ver Paso 3)
import 'package:liminal_app/database/objetivos_db.dart'; // Importa la clase ObjetivosDB refactorizada

class ListScreen extends StatefulWidget {
  const ListScreen({Key? key}) : super(key: key);

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final ObjetivosDB _databaseHelper = ObjetivosDB();

  // Estado para la lista de objetivos
  List<Map<String, dynamic>> _objectives = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadObjectives(); // Carga inicial de datos
  }

  // Función asíncrona para cargar objetivos desde la DB
  Future<void> _loadObjectives() async {
    setState(() {
      _isLoading = true;
    });
    // Llama al método específico en ObjetivosDB
    final objectivesFromDB = await _databaseHelper.getAllObjectives();
    setState(() {
      _objectives = objectivesFromDB;
      _isLoading = false;
    });
  }

  // Función para abrir el modal, pasando la función de recarga
  void _abrirModalNuevoObjetivo({Map<String, dynamic>? objectiveData}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Importante para modales complejos
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return AddObjectiveModalContent(
          onAddSuccess: _loadObjectives, // Callback para recargar la lista
          objectiveToEdit: objectiveData,
        );
      },
    );
  }

  // Función para eliminar con diálogo de confirmación
  void _eliminarObjetivo(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Eliminar objetivo',
          style: TextStyle(fontFamily: 'Instrument Serif'),
        ),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este objetivo y sus actividades?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Llama al método genérico delete de tu BD.
              // El CASCADE de SQL borrará las relaciones automáticamente.
              await _databaseHelper.delete('Objetivo', 'id', id);
              _loadObjectives(); // Recargar la lista
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // FAB (image_4.png)
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirModalNuevoObjetivo,
        backgroundColor: const Color(0xFFF4F5DB), // Color crema claro
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Nuevo objetivo',
              style: TextStyle(fontSize: 8, color: Colors.black54),
            ),
            Icon(Icons.add, color: Colors.black87),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          // Imagen de fondo con opacidad
          image: DecorationImage(
            image: AssetImage('assets/bg2.jpg'), // Tu imagen de fondo
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- 1. CABECERA FIJA (Títulos y Botones de Inicio/Filtros) ---
              // (Mismo código anterior de cabecera fija, adaptado de image_1.png/image_4.png)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Column(
                  children: [
                    const Text(
                      'ONIRONAUTICA',
                      style: TextStyle(
                        fontFamily: 'Instrument Serif',
                        fontSize: 42,
                        color: Color(0xFF7CB8C7),
                      ),
                    ),
                    const Text(
                      'Objetivos',
                      style: TextStyle(
                        fontFamily: 'Instrument Serif',
                        fontSize: 32,
                        color: Color(0xFF9EAA78),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomButton(
                          text: 'Ir a Inicio',
                          backgroundColor: const Color(0xFFD3ACFF),
                          shadowOffset: const Offset(0, 4),
                          onTap: () => Navigator.pop(context),
                        ),
                        CustomButton(
                          text: 'Filtros',
                          backgroundColor: const Color(0xFFD3ACFF),
                          shadowOffset: const Offset(0, 4),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- 2. LISTA CON SLIVERS (SliverList) ---
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // Renderizado condicional basado en el estado
                    if (_isLoading)
                      const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_objectives.isEmpty)
                      const SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'No hay objetivos',
                            style: TextStyle(
                              fontFamily: 'Instrument Serif',
                              fontSize: 28,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final obj = _objectives[index];
                            // Lógica simple: Si en BD está completado (1), es 'Completado'.
                            // Si no (0), calculamos si está vencida o en tiempo usando tu función anterior.
                            String statusFinal;
                            if (obj['completado'] == 1) {
                              statusFinal = 'Completado'; // Texto exacto
                            } else {
                              statusFinal = _calculateStatus(
                                obj['fecha_limite'],
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: ObjectiveCard(
                                // Mapeo de campos de la DB a propiedades de la tarjeta
                                titulo: obj['objetivo'],
                                fecha: obj['fecha_limite'],
                                // Asigna status basándote en la fecha u otro campo de estado si lo añades a Objetivo
                                estado: statusFinal,
                                onVerActividades: () {},
                                onEditar: () => _abrirModalNuevoObjetivo(
                                  objectiveData: obj,
                                ),
                                onEliminar: () => _eliminarObjetivo(obj['id']),
                              ),
                            );
                          }, childCount: _objectives.length),
                        ),
                      ),
                  ],
                ),
              ),

              // --- 3. BOTÓN INFERIOR ESTÁTICO (Calendario) ---
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0, top: 10.0),
                child: CustomButton(
                  text: 'Calendario',
                  backgroundColor: const Color(0xFFD3ACFF),
                  shadowOffset: const Offset(0, 4),

                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Función auxiliar para calcular el estado de la tarjeta basándose en la fecha límite
  String _calculateStatus(String dueDateStr) {
    print("Procesando fecha: '$dueDateStr'");
    try {
      // Formato esperado: dd/mm/aa (muy simplificado, usar DateFormat real es mejor)
      final parts = dueDateStr.split('/');
      if (parts.length != 3) return "en tiempo";
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final yearPart = int.parse(parts[2]);
      final year = (yearPart < 100) ? 2000 + yearPart : yearPart;
      // final year = 2000 + yearPart; // asume siglo 21

      final dueDate = DateTime(year, month, day);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      print("Fecha límite: $dueDate, Hoy: $today");
      // final today = DateTime.now();

      if (dueDate.isBefore(today)) {
        return "Vencido";
      }
      return "En tiempo";
    } catch (e) {
      print("Error parseando fecha: $e");
      return "En tiempo"; // Default
    }
  }
}
