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
      version: 6, // バージョン番号を増やす
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // アップグレードのコールバックを追加
    );
  }
  // Private helper method to get the database instance
  Future<Database> _getDatabase() async {
    return _database ??= await _initDatabase();
  }
  // Define the database schema
  static Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE puzzles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        grid TEXT,
        name TEXT,
        status INTEGER,
        creationDate TEXT,
        sharedCode TEXT,
        source INTEGER,
        memoGrid TEXT
      )
    ''');
      await db.execute('''
      CREATE TABLE playing_data(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        puzzleId INTEGER,
        currentGrid TEXT,
        time INTEGER,
        FOREIGN KEY (puzzleId) REFERENCES puzzles (id)
      )
    ''');
  }
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // バージョン1からバージョン2にアップグレードするためのスキーマ変更
      await db.execute('ALTER TABLE playing_data ADD COLUMN status INTEGER');
    }
    if (oldVersion < 3) {
      // バージョン2からバージョン3にアップグレードするためのスキーマ変更
      await db.execute('ALTER TABLE playing_data ADD COLUMN memoGrid TEXT');
    }
    if (oldVersion < 6) {
      // playing_data テーブルからすべてのデータを削除
      await db.execute('DELETE FROM playing_data');
    }
    // バージョンごとに必要なアップグレード手順を追加します。
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

  // playingDataのCRUD操作
  Future<int> insertPlayingData(PlayingData playingData) async {
    final db = await _getDatabase();
    return db.insert('playing_data', playingData.toMap());
  }

  Future<List<PlayingData>> getPlayingDataByPuzzleId(int puzzleId) async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('playing_data', where: 'puzzleId = ?', whereArgs: [puzzleId]);
    return List.generate(maps.length, (i) => PlayingData.fromMap(maps[i]));
  }

  Future<int> updatePlayingData(PlayingData playingData) async {
    final db = await _getDatabase();
    return db.update(
      'playing_data',
      playingData.toMap(),
      where: 'id = ?',
      whereArgs: [playingData.id],
    );
  }

  Future<int> deletePlayingData(int id) async {
    final db = await _getDatabase();
    return db.delete(
      'playing_data',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}
