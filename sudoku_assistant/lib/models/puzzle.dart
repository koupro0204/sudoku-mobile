import 'dart:convert';

class StatusNumber {
  static const none = 0;
  static const completed = 1;
  static const shared = 2;
}

class PlayStatusNumber {
  static const none = 0;
  static const playing = 1;
  static const completed = 2;
}
class SourceNumber {
  static const created = 0;
  static const share = 1;
}
class Puzzle {
  final int? id; // Nullable, because it will be null when we create a new puzzle
  final List<List<int>> grid;
  final String name;
  final int status; // 共有されているか、されていないか // shared or none or completed
  final DateTime creationDate;
  final String? sharedCode; // Nullable, because a puzzle might not be shared
  final int source; // 自分で作成したか、共有からか // created or shared
  PlayingData? playingData;
  Puzzle({
    this.id,
    required this.grid,
    required this.name,
    required this.status,
    required this.creationDate,
    this.sharedCode,
    required this.source,
    this.playingData,
  });
  // playingData をセットするメソッド
  void setPlayingData(PlayingData data) {
    playingData = data;
  }
  // Convert a Puzzle instance into a Map. The keys must correspond to the names of the columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'grid': jsonEncode(grid), // Encoding the grid to a JSON string
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
      grid: (jsonDecode(map['grid']) as List<dynamic>)
          .map((dynamic row) => row as List)
          .map((row) => row.map((cell) => cell as int).toList())
          .toList(),
      name: map['name'],
      status: map['status'],
      creationDate: DateTime.parse(map['creationDate']),
      sharedCode: map['sharedCode'],
      source: map['source'],
    );
  }
}

class PlayingData {
  final int? id;
  final int? puzzleId;
  final List<List<int>> currentGrid;
  final List<List<List<int>>>? memoGrid;
  final int elapsedTime;
  final int status;

  PlayingData({
    this.id,
    this.puzzleId,
    required this.currentGrid,
    this.memoGrid,
    this.elapsedTime = 0, // 初期値は0秒
    this.status = PlayStatusNumber.playing,
  });

  // PlayingDataインスタンスをMapに変換するメソッド
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'puzzleId': puzzleId,
      'currentGrid': jsonEncode(currentGrid), // グリッドをJSON文字列にエンコード
      'memoGrid': memoGrid != null ? jsonEncode(memoGrid) : null, // メモグリッドをJSON文字列にエンコード
      'time': elapsedTime,
      'status': status,
    };
  }

  // MapをPlayingDataインスタンスに変換するファクトリコンストラクタ
  factory PlayingData.fromMap(Map<String, dynamic> map) {
    return PlayingData(
      id: map['id'],
      puzzleId: map['puzzleId'],
      currentGrid: (jsonDecode(map['currentGrid']) as List<dynamic>)
          .map((dynamic row) => row as List)
          .map((row) => row.map((cell) => cell as int).toList())
          .toList(),
      memoGrid: map['memoGrid'] != null
          ? (jsonDecode(map['memoGrid']) as List<dynamic>?)
              ?.map((dynamic outerList) =>
                  (outerList as List<dynamic>)
                      .map((dynamic innerList) =>
                          (innerList as List<dynamic>).map((dynamic cell) => cell as int).toList())
                      .toList())
              .toList()
          : null,
      elapsedTime: map['time'],
      status: map['status'],
    );
  }
}


