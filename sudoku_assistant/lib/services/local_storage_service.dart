import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sudoku_assistant/models/puzzle.dart';

class LocalStorageService {
  // Static database variable
  static Database? _database;

  // Singleton instance
  static final LocalStorageService _instance = LocalStorageService._internal();

  // Factory constructor
  factory LocalStorageService() {
    return _instance;
  }

  // Named private constructor
  LocalStorageService._internal();

  // Initialize the database
  static Future<void> initialize() async {
    _database ??= await _initDatabase();
  }

  // Helper method to initialize the database
  static Future<Database> _initDatabase() async {
    var documentDirectory = await getDatabasesPath();
    String path = join(documentDirectory, 'sudokuAssistant.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Define the database schema
  static Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE puzzles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        grid TEXT,
        currentState TEXT,
        name TEXT,
        status TEXT,
        creationDate TEXT,
        sharedCode TEXT,
        source TEXT
      )
    ''');
  }

  // CRUD operations:

  // Insert a new puzzle
  Future<int> insertPuzzle(Puzzle puzzle) async {
    final db = await _getDatabase();
    return db.insert('puzzles', puzzle.toMap());
  }

  // Retrieve all puzzles
  Future<List<Puzzle>> getPuzzles() async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('puzzles');
    return List.generate(maps.length, (i) => Puzzle.fromMap(maps[i]));
  }

  // Update an existing puzzle
  Future<int> updatePuzzle(Puzzle puzzle) async {
    final db = await _getDatabase();
    return db.update(
      'puzzles',
      puzzle.toMap(),
      where: 'id = ?',
      whereArgs: [puzzle.id],
    );
  }

  // Delete a puzzle
  Future<int> deletePuzzle(int id) async {
    final db = await _getDatabase();
    return db.delete(
      'puzzles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Private helper method to get the database instance
  Future<Database> _getDatabase() async {
    return _database ??= await _initDatabase();
  }
}
