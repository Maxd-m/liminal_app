import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ObjetivosDB {
  static final nameDB =
      'ObjetivosDB'; // Cambia esto por el nombre de tu base de datos
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
      // IMPORTANTE: SQLite tiene las llaves foráneas apagadas por defecto.
      // Esta configuración las enciende para que funcionen tus relaciones.
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  _createTables(Database db, int version) async {
    // 1. Tabla CATEGORIA (Se crea primero porque 'Actividad' depende de ella)
    await db.execute('''
      CREATE TABLE Categoria(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        categoria VARCHAR(255) NOT NULL
      )
    ''');

    // 2. Tabla OBJETIVO
    await db.execute('''
      CREATE TABLE Objetivo(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        objetivo VARCHAR(255) NOT NULL,
        antecedentes TEXT,
        fecha_limite TEXT
      )
    ''');

    // 3. Tabla ACTIVIDAD (Depende de Categoria)
    await db.execute('''
      CREATE TABLE Actividad(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        actividad VARCHAR(255) NOT NULL,
        id_categoria INTEGER,
        FOREIGN KEY (id_categoria) REFERENCES Categoria(id) ON DELETE CASCADE
      )
    ''');

    // 4. Tabla Intermedia ACTIVIDAD_OBJETIVO (Depende de Actividad y Objetivo)
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
      "INSERT INTO Actividad (actividad, id_categoria) VALUES ('Mi nombre', 1)",
    );
    await db.execute(
      "INSERT INTO Actividad (actividad, id_categoria) VALUES ('A mi familia', 1)",
    );
    await db.execute(
      "INSERT INTO Actividad (actividad, id_categoria) VALUES ('El ruido', 1)",
    );

    // Insertamos 3 Actividades para la Categoría 2
    await db.execute(
      "INSERT INTO Actividad (actividad, id_categoria) VALUES ('El cielo', 2)",
    );
    await db.execute(
      "INSERT INTO Actividad (actividad, id_categoria) VALUES ('Un atardecer', 2)",
    );
    await db.execute(
      "INSERT INTO Actividad (actividad, id_categoria) VALUES ('La repetición', 2)",
    );

    // Insertamos 3 Actividades para la Categoría 3
    await db.execute(
      "INSERT INTO Actividad (actividad, id_categoria) VALUES ('Comer', 3)",
    );
    await db.execute(
      "INSERT INTO Actividad (actividad, id_categoria) VALUES ('Tomar agua', 3)",
    );
    await db.execute(
      "INSERT INTO Actividad (actividad, id_categoria) VALUES ('Simular una conversación', 3)",
    );
  }

  // --- MÉTODOS CRUD GENÉRICOS ---

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
}
