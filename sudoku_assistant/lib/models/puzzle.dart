class Puzzle {
  final int? id; // Added an optional ID for database operations
  final List<List<int>> grid;
  final List<List<int>> currentState;
  final String name;
  final String status;
  final DateTime creationDate;
  final String? sharedCode;
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
  // Constructor for an empty puzzle
  Puzzle.empty()
      : id = null,
        grid = List.generate(9, (index) => List.filled(9, 0)),
        currentState = List.generate(9, (index) => List.filled(9, 0)),
        name = "Unnamed Puzzle",
        status = "NotCompleted",  // Assuming a string representation for simplicity
        creationDate = DateTime.now(),
        sharedCode = null,
        source = "Created";  // Assuming "Created" represents puzzles created by the user

  // Convert Puzzle object to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'grid': gridToString(grid),
      'currentState': gridToString(currentState),
      'name': name,
      'status': status,
      'creationDate': creationDate.toIso8601String(),
      'sharedCode': sharedCode,
      'source': source
    };
  }

  // Convert Map to Puzzle object
  static Puzzle fromMap(Map<String, dynamic> map) {
    return Puzzle(
      id: map['id'],
      grid: stringToGrid(map['grid']),
      currentState: stringToGrid(map['currentState']),
      name: map['name'],
      status: map['status'],
      creationDate: DateTime.parse(map['creationDate']),
      sharedCode: map['sharedCode'],
      source: map['source'],
    );
  }

  // Helper function to convert a 2D list grid to a string representation
  String gridToString(List<List<int>> grid) {
    return grid.map((row) => row.join(",")).join(";");
  }

  // Helper function to convert the string representation back to a 2D list grid
  static List<List<int>> stringToGrid(String gridString) {
    return gridString.split(";").map((rowString) => rowString.split(",").map((cell) => int.parse(cell)).toList()).toList();
  }
  
}
