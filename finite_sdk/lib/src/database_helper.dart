import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// ---------------------------------------------------------------------------
// THE MEMORY MODEL
// ---------------------------------------------------------------------------
class Memory {
  final int? id;
  final int dateMillis; // The "Anchor" - Universal timestamp
  final int colorIndex; // 0-5 (The Emotion)
  final String title;
  final String description;

  const Memory({
    this.id,
    required this.dateMillis,
    required this.colorIndex,
    required this.title,
    required this.description,
  });

  Memory copy({
    int? id,
    int? dateMillis,
    int? colorIndex,
    String? title,
    String? description,
  }) =>
      Memory(
        id: id ?? this.id,
        dateMillis: dateMillis ?? this.dateMillis,
        colorIndex: colorIndex ?? this.colorIndex,
        title: title ?? this.title,
        description: description ?? this.description,
      );

  static Memory fromJson(Map<String, Object?> json) => Memory(
        id: json['id'] as int?,
        dateMillis: json['dateMillis'] as int,
        colorIndex: json['colorIndex'] as int,
        title: json['title'] as String,
        description: json['description'] as String,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'dateMillis': dateMillis,
        'colorIndex': colorIndex,
        'title': title,
        'description': description,
      };
}

// ---------------------------------------------------------------------------
// DATABASE HELPER (The Librarian)
// ---------------------------------------------------------------------------
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('finite_memories.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const intType = 'INTEGER NOT NULL';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE memories ( 
  id $idType, 
  dateMillis $intType,
  colorIndex $intType,
  title $textType,
  description $textType
  )
''');

    await db.execute('''
CREATE TABLE goals ( 
  id $idType, 
  dateMillis $intType,
  colorIndex $intType,
  title $textType,
  description $textType
  )
''');
  }

  Future<Memory> create(Memory memory) async {
    final db = await instance.database;
    final id = await db.insert('memories', memory.toJson());
    return memory.copy(id: id);
  }

  Future<Memory> readMemory(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'memories',
      columns: ['id', 'dateMillis', 'colorIndex', 'title', 'description'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Memory.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Memory>> readAllMemories() async {
    final db = await instance.database;
    // Order by date (newest first)
    final result = await db.query('memories', orderBy: 'dateMillis DESC');
    return result.map((json) => Memory.fromJson(json)).toList();
  }

  Future<int> update(Memory memory) async {
    final db = await instance.database;
    return db.update(
      'memories',
      memory.toJson(),
      where: 'id = ?',
      whereArgs: [memory.id],
    );
  }

  // --- NEW DELETE METHOD ---
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'memories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------------------------------------------------------------------------
  // GOAL OPERATIONS
  // ---------------------------------------------------------------------------

  Future<Goal> createGoal(Goal goal) async {
    final db = await instance.database;
    final id = await db.insert('goals', goal.toJson());
    return goal.copy(id: id);
  }

  Future<Goal> readGoal(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'goals',
      columns: ['id', 'dateMillis', 'colorIndex', 'title', 'description'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Goal.fromJson(maps.first);
    } else {
      throw Exception('Goal ID $id not found');
    }
  }

  Future<List<Goal>> readAllGoals() async {
    final db = await instance.database;
    // Order by date (ascending for goals? No, let's keep it flexible, effectively nearest future first usually makes sense but let's just do generic sort for now)
    final result = await db.query('goals', orderBy: 'dateMillis ASC');
    return result.map((json) => Goal.fromJson(json)).toList();
  }

  Future<int> updateGoal(Goal goal) async {
    final db = await instance.database;
    return db.update(
      'goals',
      goal.toJson(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteGoal(int id) async {
    final db = await instance.database;
    return await db.delete(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

// ---------------------------------------------------------------------------
// THE GOAL MODEL
// ---------------------------------------------------------------------------
class Goal {
  final int? id;
  final int dateMillis;
  final int colorIndex;
  final String title;
  final String description;

  const Goal({
    this.id,
    required this.dateMillis,
    required this.colorIndex,
    required this.title,
    required this.description,
  });

  Goal copy({
    int? id,
    int? dateMillis,
    int? colorIndex,
    String? title,
    String? description,
  }) =>
      Goal(
        id: id ?? this.id,
        dateMillis: dateMillis ?? this.dateMillis,
        colorIndex: colorIndex ?? this.colorIndex,
        title: title ?? this.title,
        description: description ?? this.description,
      );

  static Goal fromJson(Map<String, Object?> json) => Goal(
        id: json['id'] as int?,
        dateMillis: json['dateMillis'] as int,
        colorIndex: json['colorIndex'] as int,
        title: json['title'] as String,
        description: json['description'] as String,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'dateMillis': dateMillis,
        'colorIndex': colorIndex,
        'title': title,
        'description': description,
      };
}