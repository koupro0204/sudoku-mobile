import 'dart:io';
import 'dart:async';
import 'package:sudoku_assistant/models/puzzle.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class PuzzleService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initializeDb();
    return _database!;
  }

  static Future<Database> initializeDb() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, 'sudoku.db');
    var sudokuDb = await openDatabase(path, version: 1, onCreate: _createDb);
    return sudokuDb;
  }

  static void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE puzzle(id INTEGER PRIMARY KEY, grid TEXT, currentState TEXT, name TEXT, status TEXT, creationDate TEXT, sharedCode TEXT, source TEXT)');
  }

  // Create
  Future<int> addPuzzle(Puzzle puzzle) async {
    Database db = await database;
    var result = await db.insert('puzzle', puzzle.toMap());  // Convert Puzzle to Map for insertion
    return result;
  }

  // Read
  static Future<List<Puzzle>> getAllPuzzles() async {
    Database db = await database; // Note: 'this' won't work with static. You might need to adjust this line.
    var result = await db.query('puzzle');
    return result.map((map) => Puzzle.fromMap(map)).toList();
  }

  Future<Puzzle?> getPuzzleById(int id) async {
    Database db = await database;
    var result = await db.query('puzzle', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Puzzle.fromMap(result.first);
    }
    return null;
  }

  // Update
  Future<int> updatePuzzle(Puzzle updatedPuzzle) async {
    Database db = await database;
    var result = await db.update('puzzle', updatedPuzzle.toMap(), where: 'id = ?', whereArgs: [updatedPuzzle.id]);
    return result;
  }

  // Delete
  Future<int> deletePuzzle(int id) async {
    Database db = await database;
    var result = await db.delete('puzzle', where: 'id = ?', whereArgs: [id]);
    return result;
  }
}
