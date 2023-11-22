import 'dart:convert';

import 'package:sudoku_assistant/models/puzzle.dart';

class FirebasePuzzle {
  final int? id;
  final String? firebaseId;
  final List<List<int>> grid;
  final String name;
  final DateTime creationDate;
  final String sharedCode;
  int? puzzleId;
  Puzzle? puzzle;
  int completedPlayer;
  int numberOfPlayer;

  FirebasePuzzle({
    this.id,
    this.firebaseId,
    required this.grid,
    required this.name,
    required this.creationDate,
    required this.sharedCode,
    this.puzzleId,
    this.puzzle,
    required this.completedPlayer,
    required this.numberOfPlayer,
  });

  // JSONからFirebasePuzzleオブジェクトを生成するファクトリメソッド
  factory FirebasePuzzle.fromJson(String firebaseId, Map<String, dynamic> json) {
    return FirebasePuzzle(
      firebaseId: firebaseId,
      grid: json['grid'] != null
          ? List<List<int>>.from(json['grid'].map((row) => List<int>.from(row.map((item) => item as int))))
          : [],
      name: json['name'] as String,
      creationDate: DateTime.parse(json['creationDate'] as String),
      sharedCode: json['sharedCode'] as String,
      completedPlayer: json['completedPlayer'] as int,
      numberOfPlayer: json['numberOfPlayer'] as int,
    );
  }



  // FirebasePuzzleオブジェクトをJSONに変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'firebaseId': firebaseId,
      'grid': grid.map((row) => row.toList()).toList(),
      'name': name,
      'creationDate': creationDate.toIso8601String(),
      'sharedCode': sharedCode,
      'completedPlayer': completedPlayer,
      'numberOfPlayer': numberOfPlayer,
    };
  }

  // FirebasePuzzleオブジェクトをMapに変換するメソッド
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebaseId': firebaseId,
      'grid': jsonEncode(grid), // グリッドをJSON文字列にエンコード
      'name': name,
      'creationDate': creationDate.toIso8601String(),
      'sharedCode': sharedCode,
      'puzzleId': puzzleId,
      'completedPlayer': completedPlayer,
      'numberOfPlayer': numberOfPlayer,
    };
  }

  // MapをFirebasePuzzleオブジェクトに変換するファクトリコンストラクタ
  factory FirebasePuzzle.fromMap(Map<String, dynamic> map) {
    return FirebasePuzzle(
      id: map['id'],
      firebaseId: map['firebaseId'],
      grid: (jsonDecode(map['grid']) as List<dynamic>)
          .map((dynamic row) => row as List)
          .map((row) => row.map((cell) => cell as int).toList())
          .toList(),
      name: map['name'],
      creationDate: DateTime.parse(map['creationDate']),
      sharedCode: map['sharedCode'],
      puzzleId: map['puzzleId'],
      completedPlayer: map['completedPlayer'],
      numberOfPlayer: map['numberOfPlayer'],
    );
  }
}