import 'package:flutter/material.dart';
import 'package:liminal_app/database/objetivos_db.dart';

class CategoryDialog extends StatefulWidget {
  final ObjetivosDB databaseHelper;
  final Map<String, dynamic>? categoryToEdit;

  const CategoryDialog({
    super.key,
    required this.databaseHelper,
    this.categoryToEdit,
  });

  @override
  State<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  late final TextEditingController nameController;
  bool get isEditing => widget.categoryToEdit != null;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: isEditing ? widget.categoryToEdit!['categoria'] : '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (nameController.text.isEmpty) return;

    if (isEditing) {
      await widget.databaseHelper.updateCategory(
        widget.categoryToEdit!['id'],
        nameController.text,
      );
    } else {
      await widget.databaseHelper.insertCategory(nameController.text);
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
              isEditing ? 'Editar categoría' : 'Nombre de la categoría:',
              style: const TextStyle(
                fontFamily: 'Instrument Serif',
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 10),
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
              ),
              child: Text(
                isEditing ? 'Guardar cambios' : 'Añadir categoría',
                style: const TextStyle(
                  fontFamily: 'Instrument Serif',
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
