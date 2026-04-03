// addObjectiveModalContent_component.dart

import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:liminal_app/database/objetivos_db.dart'; // Importa ObjetivosDB
import 'package:intl/intl.dart';

class AddObjectiveModalContent extends StatefulWidget {
  final Function onAddSuccess; // Callback para recargar ListScreen
  final Map<String, dynamic>? objectiveToEdit;

  const AddObjectiveModalContent({
    Key? key,
    required this.onAddSuccess,
    this.objectiveToEdit, // <-- NUEVO
  }) : super(key: key);

  @override
  State<AddObjectiveModalContent> createState() =>
      _AddObjectiveModalContentState();
}

// Reemplaza esta parte en addObjectiveModalContent_component.dart

class _AddObjectiveModalContentState extends State<AddObjectiveModalContent> {
  final ObjetivosDB _databaseHelper =
      ObjetivosDB(); // O AppDB según como lo hayas llamado
  // final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _antecedentsController = TextEditingController();
  String _dueDate = '00/00/00';
  bool _isCompleted = false;

  List<Map<String, dynamic>> _categories = [];

  // SOLUCIÓN 1: Usar un int (ID) en lugar de un Map completo para el Dropdown
  int? _selectedCategoryId;

  List<Map<String, dynamic>> _availableActivities = [];
  List<Map<String, dynamic>> _addedActivities = [];

  // Saber si estamos en modo edición
  bool get _isEditing => widget.objectiveToEdit != null;

  // 1. NUEVA FUNCIÓN: Para abrir el DatePicker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Fecha en la que abre por defecto
      firstDate: DateTime(2000), // Fecha mínima permitida
      lastDate: DateTime(2101), // Fecha máxima permitida
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD3ACFF), // Usa el color principal de tu app
              onPrimary: Colors.black,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Formateamos la fecha a dd/MM/yyyy (ej. 25/10/2023)
        _dueDate = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();

    // <-- NUEVO: Si recibimos datos, llenamos los campos
    if (_isEditing) {
      _nameController.text = widget.objectiveToEdit!['objetivo'];
      _antecedentsController.text = widget.objectiveToEdit!['antecedentes'];
      _dueDate = widget.objectiveToEdit!['fecha_limite'];
      _isCompleted = widget.objectiveToEdit!['completado'] == 1;
      _loadExistingActivities(widget.objectiveToEdit!['id']);
    }
  }

  // <-- NUEVO: Cargar las actividades guardadas para este objetivo
  Future<void> _loadExistingActivities(int objectiveId) async {
    final existingActivities = await _databaseHelper.getActivitiesForObjective(
      objectiveId,
    );
    setState(() {
      _addedActivities = List<Map<String, dynamic>>.from(existingActivities);
    });
  }

  Future<void> _loadCategories() async {
    final categoriesFromDB = await _databaseHelper.getAllCategories();
    setState(() {
      _categories = categoriesFromDB;
      if (_categories.isNotEmpty) {
        // Guardamos solo el ID
        _selectedCategoryId = _categories.first['id'];
        _loadActivitiesByCategory(_selectedCategoryId!);
      }
    });
  }

  Future<void> _loadActivitiesByCategory(int categoryId) async {
    final activitiesFromDB = await _databaseHelper.getActivitiesByCategory(
      categoryId,
    );
    setState(() {
      _availableActivities = activitiesFromDB;
    });
  }

  // ... (Tus funciones _onAddActivity, _onRemoveAddedActivity, _onPriorityChanged se quedan igual) ...
  void _onAddActivity(Map<String, dynamic> activity) {
    final isAlreadyAdded = _addedActivities.any(
      (a) => a['idActividad'] == activity['id'],
    );
    if (!isAlreadyAdded) {
      setState(() {
        // Usamos spread operators [...] para crear una nueva lista en memoria
        _addedActivities = [
          ..._addedActivities,
          {
            'idActividad': activity['id'],
            'actividad': activity['actividad'],
            'prioridad': 1,
          },
        ];
        _availableActivities = _availableActivities
            .where((a) => a['id'] != activity['id'])
            .toList();
      });
    }
  }

  void _onRemoveAddedActivity(int activityId) {
    setState(() {
      // _addedActivities.removeWhere((a) => a['idActividad'] == activityId);
      _addedActivities = _addedActivities
          .where((a) => a['idActividad'] != activityId)
          .toList();
    });
  }

  void _onPriorityChanged(int activityId, int newPriority) {
    setState(() {
      final activityIndex = _addedActivities.indexWhere(
        (a) => a['idActividad'] == activityId,
      );
      if (activityIndex != -1) {
        _addedActivities[activityIndex]['prioridad'] = newPriority;
      }
    });
  }

  Future<void> _onAddObjectiveToDatabase() async {
    if (_addedActivities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Añade al menos una actividad')),
      );
      return;
    }

    bool success;

    // Si estamos editando, llamamos a update, si no, a add
    if (_isEditing) {
      success = await _databaseHelper.updateObjectiveWithActivities(
        id: widget.objectiveToEdit!['id'],
        name: _nameController.text,
        antecedents: _antecedentsController.text,
        dueDate: _dueDate,
        isCompleted: _isCompleted,
        activitiesWithPriorities: _addedActivities,
      );
    } else {
      success = await _databaseHelper.addObjectiveWithActivities(
        name: _nameController.text,
        antecedents: _antecedentsController.text,
        dueDate: _dueDate,
        isCompleted: _isCompleted,
        activitiesWithPriorities: _addedActivities,
      );
    }

    if (success) {
      widget.onAddSuccess();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Objetivo actualizado' : 'Objetivo añadido con éxito',
          ),
        ),
      );
    }

    // final success = await _databaseHelper.addObjectiveWithActivities(
    //   name: _nameController.text,
    //   antecedents: _antecedentsController.text,
    //   dueDate: _dueDate,
    //   isCompleted: _isCompleted,
    //   activitiesWithPriorities: _addedActivities
    //       .map(
    //         (a) => {
    //           'idActividad': a['idActividad'],
    //           'prioridad': a['prioridad'],
    //         },
    //       )
    //       .toList(),
    // );

    // if (success) {
    //   widget.onAddSuccess();
    //   Navigator.pop(context);
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Objetivo añadido con éxito')),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    const modalStyle = TextStyle(
      fontFamily: 'Instrument Serif',
      color: Colors.black87,
    );

    return Container(
      padding: const EdgeInsets.all(24.0),
      // Aumentamos un poco el tamaño por si acaso, o puedes dejarlo en 0.85
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Color(0xFFF4F5DB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // SOLUCIÓN 2: Envolver todo en un SingleChildScrollView para evitar el overflow
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Cambiamos minAxisSize para que la columna se adapte al contenido
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reemplaza el Center actual con este:
            Center(
              child: Column(
                children: [
                  Text(
                    _isEditing ? 'Editar objetivo' : 'Nuevo objetivo',
                    style: const TextStyle(
                      fontFamily: 'Instrument Serif',
                      fontSize: 28,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // NUEVO: Texto de Cantidad y Badge
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Cantidad actividades: ',
                        style: TextStyle(
                          fontFamily: 'Instrument Serif',
                          fontSize: 20,
                          color: Colors
                              .black54, // Un poco más tenue para diferenciar del título
                        ),
                      ),
                      const SizedBox(width: 4),
                      badges.Badge(
                        badgeContent: Text(
                          '${_addedActivities.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        badgeStyle: const badges.BadgeStyle(
                          // Usando el morado de tu tema para que combine
                          badgeColor: Color(0xFFD3ACFF),
                          padding: EdgeInsets.all(6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildTextField(label: 'Nombre', controller: _nameController),
            _buildTextField(
              label: 'Antecedentes',
              controller: _antecedentsController,
            ),
            _buildDateField(
              label: 'Fecha limite',
              dueDate: _dueDate,
              onDatePickerTap: () => _selectDate(context),
            ),

            Theme(
              data: ThemeData(unselectedWidgetColor: Colors.black54),
              child: CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  '¿Marcar como completado?',
                  style: modalStyle,
                ),
                value: _isCompleted,
                activeColor: const Color(0xFF9EAA78),
                checkColor: Colors.white,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (bool? newValue) {
                  setState(() {
                    _isCompleted = newValue ?? false;
                  });
                },
              ),
            ),

            const SizedBox(height: 10),
            const Text(
              'Actividades añadidas (con prioridades):',
              style: modalStyle,
            ),
            const SizedBox(height: 10),

            // SOLUCIÓN 2 (Continuación): Quitamos el 'Expanded' y usamos un Container con altura fija
            Container(
              height:
                  140, // Altura fija para hacer scroll solo en las actividades añadidas
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                color: Colors.white70,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _addedActivities.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final addedAct = _addedActivities[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(addedAct['actividad'], style: modalStyle),
                        ),
                        _buildPriorityDropdown(
                          currentPriority: addedAct['prioridad'],
                          onChanged: (newPri) => _onPriorityChanged(
                            addedAct['idActividad'],
                            newPri!,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          onPressed: () =>
                              _onRemoveAddedActivity(addedAct['idActividad']),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Añadir actividad',
                    style: TextStyle(
                      fontFamily: 'Instrument Serif',
                      fontSize: 24,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Categoria', style: modalStyle),

                      // SOLUCIÓN 1 (Continuación): DropdownButton configurado para usar INT
                      DropdownButton<int>(
                        value: _selectedCategoryId, // Pasamos el ID
                        items: _categories.map((cat) {
                          return DropdownMenuItem<int>(
                            value: cat['id'] as int, // El valor es el ID
                            child: Text(cat['categoria'].toString()),
                          );
                        }).toList(),
                        onChanged: (newCategoryId) {
                          setState(() {
                            _selectedCategoryId = newCategoryId;
                            if (newCategoryId != null) {
                              _loadActivitiesByCategory(newCategoryId);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _availableActivities.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final availAct = _availableActivities[index];
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                availAct['actividad'],
                                style: modalStyle,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _onAddActivity(availAct),
                              child: const Text(
                                'Añadir',
                                style: TextStyle(
                                  color: Colors.cyan,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Center(
              child: MaterialButton(
                onPressed: _onAddObjectiveToDatabase,
                color: const Color(0xFFD3ACFF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 10,
                ),
                child: Text(
                  _isEditing ? 'Guardar cambios' : 'Añadir objetivo',
                  style: TextStyle(
                    fontFamily: 'Instrument Serif',
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            // Un poco de espacio extra al final por si el usuario hace scroll hasta el tope
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- (Tus funciones auxiliares _buildTextField, _buildDateField, _buildPriorityDropdown quedan igual) ---
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Instrument Serif',
            color: Colors.black,
          ),
        ),
        TextField(
          controller: controller,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required String dueDate,
    required VoidCallback onDatePickerTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Instrument Serif',
            color: Colors.black,
          ),
        ),
        GestureDetector(
          onTap: onDatePickerTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dueDate, style: const TextStyle(color: Colors.black)),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildPriorityDropdown({
    required int currentPriority,
    required ValueChanged<int?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButton<int>(
        value: currentPriority,
        items: List.generate(10, (index) => index + 1).map((pri) {
          return DropdownMenuItem<int>(value: pri, child: Text(pri.toString()));
        }).toList(),
        onChanged: onChanged,
        underline: const SizedBox(),
      ),
    );
  }
}
