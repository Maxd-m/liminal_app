import 'package:flutter/material.dart';
import 'package:liminal_app/database/objetivos_db.dart';

class ActivityDialog extends StatefulWidget {
  final ObjetivosDB databaseHelper;
  final List<Map<String, dynamic>> categories;
  final Map<String, dynamic>? activityToEdit;

  const ActivityDialog({
    super.key,
    required this.databaseHelper,
    required this.categories,
    this.activityToEdit,
  });

  @override
  State<ActivityDialog> createState() => _ActivityDialogState();
}

class _ActivityDialogState extends State<ActivityDialog> {
  late final TextEditingController nameController;
  int? selectedCategoryId;

  bool get isEditing => widget.activityToEdit != null;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: isEditing ? widget.activityToEdit!['actividad'] : '',
    );

    selectedCategoryId = isEditing
        ? widget.activityToEdit!['categoria_id']
        : (widget.categories.isNotEmpty ? widget.categories.first['id'] : null);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (nameController.text.isEmpty || selectedCategoryId == null) return;

    if (isEditing) {
      await widget.databaseHelper.updateActivity(
        widget.activityToEdit!['id'],
        nameController.text,
        selectedCategoryId!,
      );
    } else {
      await widget.databaseHelper.insertActivity(
        nameController.text,
        selectedCategoryId!,
      );
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFD3D3D3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEditing ? 'Editar actividad' : 'Añadir actividad',
              style: const TextStyle(
                fontFamily: 'Instrument Serif',
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 20),

            // --- DROPDOWN CATEGORÍA ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categoria',
                  style: TextStyle(
                    fontFamily: 'Instrument Serif',
                    fontSize: 18,
                  ),
                ),
                Container(
                  color: const Color(0xFF5E8088),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DropdownButton<int>(
                    value: selectedCategoryId,
                    dropdownColor: const Color(0xFF5E8088),
                    iconEnabledColor: Colors.white,
                    underline: const SizedBox(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Instrument Serif',
                    ),
                    items: widget.categories.map((cat) {
                      return DropdownMenuItem<int>(
                        value: cat['id'] as int,
                        child: Text(cat['categoria'].toString()),
                      );
                    }).toList(),
                    onChanged: (newId) {
                      setState(() {
                        selectedCategoryId = newId;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Nombre de la actividad:',
                style: TextStyle(fontFamily: 'Instrument Serif', fontSize: 18),
              ),
            ),

            const SizedBox(height: 5),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFF5E8088),
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
              style: const TextStyle(color: Colors.white),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD3ACFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                isEditing ? 'Guardar cambios' : 'Añadir actividad',
                style: const TextStyle(
                  fontFamily: 'Instrument Serif',
                  color: Colors.black87,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
