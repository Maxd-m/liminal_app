import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:liminal_app/components/button_component.dart';
import 'package:liminal_app/database/objetivos_db.dart';
import 'package:liminal_app/utils/addObjectiveModalContent_component.dart';
import 'package:liminal_app/utils/dayObjectivesModalContent_component.dart'; // Crearemos este archivo después

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ObjetivosDB _databaseHelper = ObjetivosDB();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Mapa para agrupar objetivos por día exacto
  Map<DateTime, List<Map<String, dynamic>>> _groupedObjectives = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadAndGroupObjectives();
  }

  // --- Lógica de Datos ---

  Future<void> _loadAndGroupObjectives() async {
    setState(() => _isLoading = true);

    final allObjectives = await _databaseHelper.getAllObjectives();
    Map<DateTime, List<Map<String, dynamic>>> grouped = {};

    for (var obj in allObjectives) {
      DateTime? date = _parseDate(obj['fecha_limite']);
      if (date != null) {
        // Usamos solo año, mes y día para agrupar correctamente
        DateTime normalizedDate = DateTime.utc(date.year, date.month, date.day);

        if (grouped[normalizedDate] == null) {
          grouped[normalizedDate] = [];
        }
        grouped[normalizedDate]!.add(obj);
      }
    }

    setState(() {
      _groupedObjectives = grouped;
      _isLoading = false;
    });
  }

  DateTime? _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length != 3) return null;
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final yearPart = int.parse(parts[2]);
      final year = yearPart < 100 ? 2000 + yearPart : yearPart;
      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    // Normalizamos el día para buscar en el mapa
    DateTime normalizedDate = DateTime.utc(day.year, day.month, day.day);
    return _groupedObjectives[normalizedDate] ?? [];
  }

  // Helper para determinar el color del punto
  Color _getMarkerColor(Map<String, dynamic> obj, DateTime dueDate) {
    if (obj['completado'] == 1) {
      return Colors.white; // Completado
    }

    // Normalizamos "hoy" para la comparación justa
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (dueDate.isBefore(today)) {
      return Colors.red; // Vencido/Cancelado
    } else {
      return Colors.green; // Por cumplir / En tiempo
    }
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
          onAddSuccess:
              _loadAndGroupObjectives, // Callback para recargar la lista
          objectiveToEdit: objectiveData,
        );
      },
    );
  }

  // --- UI ---

  void _abrirModalDia(
    DateTime selectedDay,
    List<Map<String, dynamic>> dayObjectives,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent, // Para manejar nuestro propio diseño de fondo
      builder: (context) {
        return DayObjectivesModalContent(
          selectedDate: selectedDay,
          objectives: dayObjectives,
          onReloadRequired:
              _loadAndGroupObjectives, // Para recargar si eliminan/editan en el modal
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirModalNuevoObjetivo, // Tu modal de nuevo objetivo
        backgroundColor: const Color(0xFFF4F5DB),
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
          image: DecorationImage(
            image: AssetImage('assets/bg2.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- 1. CABECERA ---
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CustomButton(
                        text: 'Ir a Inicio',
                        backgroundColor: const Color(0xFFD3ACFF),
                        shadowOffset: const Offset(0, 4),
                        onTap: () => Navigator.pushNamed(context, "/home"),
                      ),
                    ),
                  ],
                ),
              ),

              // --- 2. CALENDARIO ---
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF9EAA78),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    195,
                                    244,
                                    245,
                                    219,
                                  ), // Fondo claro del calendario
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(8.0),
                                child: TableCalendar(
                                  firstDay: DateTime.utc(2020, 10, 16),
                                  lastDay: DateTime.utc(2030, 3, 14),
                                  focusedDay: _focusedDay,
                                  selectedDayPredicate: (day) =>
                                      isSameDay(_selectedDay, day),
                                  onDaySelected: (selectedDay, focusedDay) {
                                    setState(() {
                                      _selectedDay = selectedDay;
                                      _focusedDay = focusedDay;
                                    });

                                    final dayObjectives = _getEventsForDay(
                                      selectedDay,
                                    );
                                    if (dayObjectives.isNotEmpty) {
                                      _abrirModalDia(
                                        selectedDay,
                                        dayObjectives,
                                      );
                                    }
                                  },
                                  eventLoader: _getEventsForDay,
                                  // Estilos básicos
                                  headerStyle: const HeaderStyle(
                                    formatButtonVisible: false,
                                    titleCentered: true,
                                  ),
                                  calendarStyle: const CalendarStyle(
                                    todayDecoration: BoxDecoration(
                                      color: Color(0xFF9EAA78),
                                      shape: BoxShape.circle,
                                    ),
                                    selectedDecoration: BoxDecoration(
                                      color: Color(0xFF7CB8C7),
                                      shape: BoxShape.circle,
                                    ),
                                    outsideDaysVisible: false,
                                  ),
                                  // Constructores personalizados para los PUNTOS
                                  calendarBuilders: CalendarBuilders(
                                    markerBuilder: (context, date, events) {
                                      if (events.isEmpty)
                                        return const SizedBox();
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: events.take(4).map((event) {
                                          // Mostramos max 4 puntos para no desbordar
                                          final obj =
                                              event as Map<String, dynamic>;
                                          final markerColor = _getMarkerColor(
                                            obj,
                                            date,
                                          );
                                          return Container(
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 1.5,
                                            ),
                                            width: 8.0,
                                            height: 8.0,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: markerColor,
                                              border: Border.all(
                                                color: Colors.black26,
                                                width: 0.5,
                                              ), // Borde sutil para el blanco
                                            ),
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              // --- 3. SIMBOLOGÍA ---
                              const Text(
                                'Simbologia',
                                style: TextStyle(
                                  fontFamily: 'Instrument Serif',
                                  fontSize: 32,
                                  color: Color(0xFF9EAA78),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildSimbologiaItem(
                                    'Completado',
                                    Colors.white,
                                  ),
                                  _buildSimbologiaItem(
                                    'En tiempo',
                                    Colors.green,
                                  ),
                                  _buildSimbologiaItem('Vencido', Colors.red),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'La cantidad de puntos representa la cantidad y estado de los objetivos con fecha limite en el dia seleccionado',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Instrument Serif',
                                  fontSize: 18,
                                  color: Colors.white70,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),

              // --- 4. BOTÓN INFERIOR ---
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0, top: 10.0),
                child: CustomButton(
                  text: 'Listado',
                  backgroundColor: const Color(0xFFD3ACFF),
                  shadowOffset: const Offset(0, 4),
                  onTap: () => Navigator.pop(context), // Vuelve a la lista
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimbologiaItem(String label, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Instrument Serif',
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black26, width: 1),
          ),
        ),
      ],
    );
  }
}
