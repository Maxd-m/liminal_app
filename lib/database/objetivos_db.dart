// objetivos_db.dart (Basado en ObjetivosDB del turno anterior)

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ObjetivosDB {
  static final nameDB = 'objetivosdb'; // Nombre de base de datos
  static final versionDB = 1;

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    return _database = await _initDatabase();
  }

  Future<Database?> _initDatabase() async {
    Directory folder = await getApplicationDocumentsDirectory();
    String pathDB = join(folder.path, nameDB);

    return openDatabase(
      pathDB,
      version: versionDB,
      onCreate: _createTables,
      // Enciende las llaves foráneas para que funcionen las relaciones
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  _createTables(Database db, int version) async {
    // 1. Creación de Tablas (Mismo código anterior)
    await db.execute('''
      CREATE TABLE Categoria(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        categoria VARCHAR(255) NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Objetivo(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        objetivo VARCHAR(255) NOT NULL,
        antecedentes TEXT,
        fecha_limite TEXT,
        completado INTEGER DEFAULT 0 -- 0 = Falso, 1 = Verdadero
      )
    ''');

    await db.execute('''
      CREATE TABLE Actividad(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        actividad VARCHAR(255) NOT NULL,
        id_categoria INTEGER,
        FOREIGN KEY (id_categoria) REFERENCES Categoria(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE Actividad_Objetivo(
        id_objetivo INTEGER,
        id_actividad INTEGER,
        prioridad_actividad INTEGER CHECK(prioridad_actividad >= 1 AND prioridad_actividad <= 10),
        PRIMARY KEY (id_objetivo, id_actividad),
        FOREIGN KEY (id_objetivo) REFERENCES Objetivo(id) ON DELETE CASCADE,
        FOREIGN KEY (id_actividad) REFERENCES Actividad(id) ON DELETE CASCADE
      )
    ''');

    // --- INSERCIÓN DE DATOS INICIALES (SEEDING) ---

    // Insertamos 3 Categorías
    // Nota: Al ser la BD nueva, los IDs serán 1, 2 y 3 automáticamente.
    await db.execute(
      "INSERT INTO Categoria (categoria) VALUES ('Recordar'), ('Admirar'), ('Sobrevivir')",
    );

    // Insertamos 3 Actividades para la Categoría 1
    await db.execute(
      "INSERT INTO Actividad (actividad, id_categoria) VALUES ('Mi nombre (recordar)', 1)",
    );
    await db.execute(
      "INSERT INTO Actividad (actividad, id_categoria) VALUES ('A mi familia (recordar)', 1)",
    );
    await db.execute(
      "INSERT INTO Actividad (actividad, id_categoria) VALUES ('El ruido (recordar)', 1)",
    );

    // Insertamos 3 Actividades para la Categoría 2
    await db.execute(
      "INSERT INTO Actividad (actividad, id_categoria) VALUES ('El cielo (admirar)', 2)",
    );
    await db.execute(
      "INSERT INTO Actividad (actividad, id_categoria) VALUES ('Un atardecer (admirar)', 2)",
    );
    await db.execute(
      "INSERT INTO Actividad (actividad, id_categoria) VALUES ('La repetición (admirar)', 2)",
    );

    // Insertamos 3 Actividades para la Categoría 3
    await db.execute(
      "INSERT INTO Actividad (actividad, id_categoria) VALUES ('Comer (sobrevivir)', 3)",
    );
    await db.execute(
      "INSERT INTO Actividad (actividad, id_categoria) VALUES ('Tomar agua (sobrevivir)', 3)",
    );
    await db.execute(
      "INSERT INTO Actividad (actividad, id_categoria) VALUES ('Simular una conversación (sobrevivir)', 3)",
    );
  }

  // --- MÉTODOS CRUD GENÉRICOS (Keep them, as they are useful) ---
  // (select, update, delete genéricos del turno anterior)
  Future<int> insert(String table, Map<String, dynamic> data) async {
    var conexion = await database;
    return conexion!.insert(table, data);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data,
    String idColumnName,
  ) async {
    var conexion = await database;
    // Se pide 'idColumnName' por si la llave primaria se llama distinto ('id' vs 'id_objetivo')
    return conexion!.update(
      table,
      data,
      where: '$idColumnName = ?',
      whereArgs: [data[idColumnName]],
    );
  }

  Future<int> delete(String table, String idColumnName, int id) async {
    var conexion = await database;
    return conexion!.delete(table, where: '$idColumnName = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> select(String table) async {
    var conexion = await database;
    return await conexion!.query(table);
  }

  // --- MÉTODOS DE BASE DE DATOS ESPECÍFICOS PARA LA PANTALLA ---

  // 1. Obtener todos los objetivos para ListScreen
  Future<List<Map<String, dynamic>>> getAllObjectives() async {
    return await select('Objetivo');
  }

  // 2. Obtener todas las categorías para el modal
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    return await select('Categoria');
  }

  // 3. Obtener actividades para una categoría específica para el modal
  Future<List<Map<String, dynamic>>> getActivitiesByCategory(
    int categoryId,
  ) async {
    var conexion = await database;
    return await conexion!.query(
      'Actividad',
      where: 'id_categoria = ?',
      whereArgs: [categoryId],
    );
  }

  // 4. Transacción compleja: Añadir un Objetivo y sus relaciones con actividades
  Future<int> addObjectiveWithActivities({
    required String name,
    required String antecedents,
    required String dueDate,
    required bool isCompleted, // <-- NUEVO PARÁMETRO
    required List<Map<String, dynamic>> activitiesWithPriorities,
  }) async {
    var db = await database;
    int objectiveId =
        -1; // Variable para almacenar el ID del objetivo insertado
    try {
      await db!.transaction((txn) async {
        objectiveId = await txn.insert('Objetivo', {
          'objetivo': name,
          'antecedentes': antecedents,
          'fecha_limite': dueDate,
          'completado': isCompleted ? 1 : 0, // <-- GUARDAR COMO 1 o 0
        });

        for (var actWithPri in activitiesWithPriorities) {
          await txn.insert('Actividad_Objetivo', {
            'id_objetivo': objectiveId,
            'id_actividad': actWithPri['idActividad'],
            'prioridad_actividad': actWithPri['prioridad'],
          });
        }
      });
      return objectiveId;
    } catch (e) {
      print('Error al añadir objetivo: $e');
      return -1;
    }
  }

  // 5. Obtener las actividades vinculadas a un objetivo específico (Para Editar)
  Future<List<Map<String, dynamic>>> getActivitiesForObjective(
    int objectiveId,
  ) async {
    var db = await database;
    // Hacemos un JOIN para traer el nombre de la actividad y la prioridad guardada
    return await db!.rawQuery(
      '''
      SELECT a.id as idActividad, a.actividad, ao.prioridad_actividad as prioridad
      FROM Actividad a
      INNER JOIN Actividad_Objetivo ao ON a.id = ao.id_actividad
      WHERE ao.id_objetivo = ?
    ''',
      [objectiveId],
    );
  }

  // 6. Transacción para Actualizar un Objetivo y sus actividades
  Future<int> updateObjectiveWithActivities({
    required int id,
    required String name,
    required String antecedents,
    required String dueDate,
    required bool isCompleted,
    required List<Map<String, dynamic>> activitiesWithPriorities,
  }) async {
    var db = await database;
    try {
      await db!.transaction((txn) async {
        // 1. Actualizamos los datos principales del objetivo
        await txn.update(
          'Objetivo',
          {
            'objetivo': name,
            'antecedentes': antecedents,
            'fecha_limite': dueDate,
            'completado': isCompleted ? 1 : 0,
          },
          where: 'id = ?',
          whereArgs: [id],
        );

        // 2. Borramos las relaciones anteriores en Actividad_Objetivo
        await txn.delete(
          'Actividad_Objetivo',
          where: 'id_objetivo = ?',
          whereArgs: [id],
        );

        // 3. Insertamos las relaciones actualizadas (nuevas, editadas o conservadas)
        for (var actWithPri in activitiesWithPriorities) {
          await txn.insert('Actividad_Objetivo', {
            'id_objetivo': id,
            'id_actividad': actWithPri['idActividad'],
            'prioridad_actividad': actWithPri['prioridad'],
          });
        }
      });
      return 1;
    } catch (e) {
      print('Error al actualizar objetivo: $e');
      return -1;
    }
  }

  // 7. Obtener todas las actividades junto con el nombre de su categoría
  Future<List<Map<String, dynamic>>> getAllActivities() async {
    var db = await database;
    // Usamos un JOIN para traer el nombre de la categoría y poder mostrarlo en el subtítulo
    return await db!.rawQuery('''
SELECT a.id, a.actividad, c.categoria as nombre_categoria
 FROM Actividad a
 INNER JOIN Categoria c ON a.id_categoria = c.id
 ''');
  }

  // 8. Insertar una nueva categoría
  Future<int> insertCategory(String categoryName) async {
    return await insert('Categoria', {'categoria': categoryName});
  }

  // 9. Insertar una nueva actividad vinculada a una categoría
  Future<int> insertActivity(String activityName, int categoryId) async {
    return await insert('Actividad', {
      'actividad': activityName,
      'id_categoria': categoryId,
    });
  }

  // 10. Eliminar una categoría
  Future<int> deleteCategory(int id) async {
    // Gracias a "ON DELETE CASCADE" en tu tabla, al borrar una categoría
    // se borrarán en cascada las actividades asociadas a ella.
    return await delete('Categoria', 'id', id);
  }

  // 11. Eliminar una actividad
  Future<int> deleteActivity(int id) async {
    return await delete('Actividad', 'id', id);
  }

  // 12. Actualizar una categoría usando el método genérico
  Future<int> updateCategory(int id, String categoryName) async {
    return await update(
      'Categoria',
      {'id': id, 'categoria': categoryName},
      'id', // Nombre de la columna de la llave primaria
    );
  }

  // 13. Actualizar una actividad usando el método genérico
  Future<int> updateActivity(
    int id,
    String activityName,
    int categoryId,
  ) async {
    return await update(
      'Actividad',
      {'id': id, 'actividad': activityName, 'id_categoria': categoryId},
      'id', // Nombre de la columna de la llave primaria
    );
  }
}
