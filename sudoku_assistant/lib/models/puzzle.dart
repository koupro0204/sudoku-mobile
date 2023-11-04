import 'dart:convert';

class Puzzle {
  final int? id; // Nullable, because it will be null when we create a new puzzle
  final List<List<int>> grid;
  final List<List<int>> currentState;
  final String name;
  final String status;
  final DateTime creationDate;
  final String? sharedCode; // Nullable, because a puzzle might not be shared
  final String source;

  Puzzle({
    this.id,
    required this.grid,
    required this.currentState,
    required this.name,
    required this.status,
    required this.creationDate,
    this.sharedCode,
    required this.source,
  });

  // Convert a Puzzle instance into a Map. The keys must correspond to the names of the columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'grid': jsonEncode(grid), // Encoding the grid to a JSON string
      'currentState': jsonEncode(currentState), // Encoding the currentState to a JSON string
      'name': name,
      'status': status,
      'creationDate': creationDate.toIso8601String(), // Storing the date as a string
      'sharedCode': sharedCode,
      'source': source,
    };
  }

  // Convert a Map into a Puzzle instance
  factory Puzzle.fromMap(Map<String, dynamic> map) {
    return Puzzle(
      id: map['id'],
      grid: jsonDecode(map['grid']),
      currentState: jsonDecode(map['currentState']),
      name: map['name'],
      status: map['status'],
      creationDate: DateTime.parse(map['creationDate']),
      sharedCode: map['sharedCode'],
      source: map['source'],
    );
  }
}
