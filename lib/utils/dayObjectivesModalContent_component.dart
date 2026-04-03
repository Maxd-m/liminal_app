import 'package:flutter/material.dart';
import 'package:liminal_app/components/button_component.dart';
import 'package:liminal_app/utils/addObjectiveModalContent_component.dart';
import 'package:liminal_app/components/objectiveCard_component.dart';
import 'package:liminal_app/database/objetivos_db.dart';

class DayObjectivesModalContent extends StatefulWidget {
  final DateTime selectedDate;
  final List<Map<String, dynamic>> objectives;
  final VoidCallback onReloadRequired;

  const DayObjectivesModalContent({
    Key? key,
    required this.selectedDate,
    required this.objectives,
    required this.onReloadRequired,
  }) : super(key: key);

  @override
  State<DayObjectivesModalContent> createState() =>
      _DayObjectivesModalContentState();
}

class _DayObjectivesModalContentState extends State<DayObjectivesModalContent> {
  final ObjetivosDB _databaseHelper = ObjetivosDB();

  // Estado para la lista de objetivos
  // List<Map<String, dynamic>> _objectives = [];
  // bool _isLoading = true;

  // NUEVO: Variable para el filtro (Todos, En tiempo, Vencido, Completado)
  String _selectedFilter = 'Todos';

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  String _calculateStatusForCard(Map<String, dynamic> obj, DateTime dueDate) {
    if (obj['completado'] == 1) return 'Completado';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (dueDate.isBefore(today)) return 'Vencido';
    return 'En tiempo';
  }

  void _abrirModalNuevoObjetivo({Map<String, dynamic>? objectiveData}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return AddObjectiveModalContent(
          // NUEVO: Al guardar con éxito en el form, cerramos este modal (Day Modal)
          // y actualizamos el calendario
          onAddSuccess: () {
            Navigator.pop(context); // Cierra la vista de objetivos del día
            widget.onReloadRequired(); // Recarga los puntos del calendario
          },
          objectiveToEdit: objectiveData,
        );
      },
    );
  }

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
            onPressed: () => Navigator.pop(context), // Solo cierra el alert
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Cierra el Alert Dialog

              await _databaseHelper.delete('Objetivo', 'id', id);

              // NUEVO: Al eliminar, cerramos el modal del día y actualizamos el calendario
              if (mounted) {
                Navigator.pop(context); // Cierra la vista de objetivos del día
                widget.onReloadRequired(); // Recarga los puntos del calendario
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDate(widget.selectedDate);

    // --- CORRECCIÓN 1: Filtrar sobre widget.objectives ---
    final filteredObjectives = widget.objectives.where((obj) {
      if (_selectedFilter == 'Todos') return true;

      // Reutilizamos tu función _calculateStatusForCard para evitar duplicar lógica
      String status = _calculateStatusForCard(obj, widget.selectedDate);

      return status == _selectedFilter;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: const BoxDecoration(
        color: Color(0xFF8C8C8C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Objetivos del dia: $dateStr',
            style: const TextStyle(
              fontFamily: 'Instrument Serif',
              fontSize: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            // Actualizamos para que muestre la cantidad de la lista filtrada
            'Cantidad: ${filteredObjectives.length}',
            style: const TextStyle(
              fontFamily: 'Instrument Serif',
              fontSize: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Filtros',
            backgroundColor: const Color(0xFFD3ACFF),
            shadowOffset: const Offset(0, 4),
            onTap: () async {
              final result = await showMenu<String>(
                context: context,
                position: const RelativeRect.fromLTRB(100, 200, 20, 0),
                items: [
                  const PopupMenuItem(value: 'Todos', child: Text('Todos')),
                  const PopupMenuItem(
                    value: 'En tiempo',
                    child: Text('En tiempo'),
                  ),
                  const PopupMenuItem(value: 'Vencido', child: Text('Vencido')),
                  const PopupMenuItem(
                    value: 'Completado',
                    child: Text('Completado'),
                  ),
                ],
              );

              if (result != null) {
                setState(() {
                  _selectedFilter = result;
                });
              }
            },
          ),
          const SizedBox(height: 20),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              // --- CORRECCIÓN 2: Usar filteredObjectives en el ListView ---
              itemCount: filteredObjectives.length,
              itemBuilder: (context, index) {
                // Obtenemos el objeto de la lista ya filtrada
                final obj = filteredObjectives[index];

                final statusStr = _calculateStatusForCard(
                  obj,
                  widget.selectedDate,
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ObjectiveCard(
                    titulo: obj['objetivo'],
                    fecha: obj['fecha_limite'],
                    estado: statusStr,
                    onVerActividades: () {},
                    onEditar: () =>
                        _abrirModalNuevoObjetivo(objectiveData: obj),
                    onEliminar: () => _eliminarObjetivo(obj['id']),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: CustomButton(
              text: 'Cerrar',
              backgroundColor: const Color(0xFFD3ACFF),
              shadowOffset: const Offset(0, 4),
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
