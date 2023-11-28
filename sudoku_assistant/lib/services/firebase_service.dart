import 'package:sudoku_assistant/models/firebase_puzzle.dart';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';

class FirebasePuzzleService {
  DatabaseReference _ref = FirebaseDatabase.instance.ref("firebasePuzzles");

  Future<void> addFirebasePuzzle(FirebasePuzzle puzzle) async {
    await _ref.push().set(puzzle.toJson());
  }

  Future<FirebasePuzzle?> getFirebasePuzzleBySharedCord(String sharedCode) async {
    Query sharedCodeQuery = _ref.orderByChild("sharedCode").equalTo(sharedCode);
    DataSnapshot sharedCodeSnapshot = (await sharedCodeQuery.once()).snapshot; // キャスト追加
    if (sharedCodeSnapshot.value != null) {
      // Firebaseから取得したデータをMap<String, dynamic>に変換
      Map<String, dynamic> data = Map<String, dynamic>.from(sharedCodeSnapshot.value as Map).cast<String, dynamic>();
      // パズルのIDを取得（共有コードに一致する最初のパズルのID）
      String puzzleId = data.keys.first;

      // パズルデータを取得し、Map<String, dynamic> に安全にキャスト
      Map<String, dynamic> puzzleData = (data[puzzleId] as Map).cast<String, dynamic>();


      // FirebasePuzzle.fromJsonを呼び出して、FirebasePuzzleオブジェクトを作成
      return FirebasePuzzle.fromJson(puzzleId, puzzleData);
    }
    return null;
  }

  Future<void> updateFirebasePuzzle(FirebasePuzzle updatedPuzzle) async {
    DatabaseReference ref = _ref.child(updatedPuzzle.firebaseId!);
    await ref.update(updatedPuzzle.toJson());
  }

  Future<void> updateNumberOfPlayer(FirebasePuzzle puzzle) async {
    print("updateNumberOfPlayer: ",);
    print(puzzle.firebaseId!);
    DatabaseReference ref = _ref.child(puzzle.firebaseId!);
    await ref.runTransaction((Object? puzzleData) {
      print("updateNumberOfPlayer object $puzzleData");
      if (puzzleData == null) {
        return Transaction.abort();
      }
      // パズルデータをMap<dynamic, dynamic>にキャスト
      Map<dynamic, dynamic> puzzleMap = puzzleData as Map<dynamic, dynamic>;

      // numberOfPlayerをインクリメント
      puzzleMap['numberOfPlayer'] = puzzleMap['numberOfPlayer'] + 1;

      // 更新したパズルデータを返す
      return Transaction.success(puzzleMap);
    });
  }
  Future<FirebasePuzzle?> updateCompletedOfPlayer(FirebasePuzzle puzzle) async {
    DatabaseReference ref = _ref.child(puzzle.firebaseId!);
    await ref.runTransaction((Object? puzzleData) {
      if (puzzleData == null) {
        return Transaction.abort();
      }
      Map<dynamic, dynamic> puzzleMap = puzzleData as Map<dynamic, dynamic>;

      // Map<String, dynamic> puzzleMap = puzzleData as Map<String, dynamic>;
      puzzleMap['completedPlayer'] = puzzleMap['completedPlayer'] + 1; // nullチェックを追加
      return Transaction.success(puzzleMap);
    });

    DataSnapshot updatedSnapshot = await ref.get();
    if (updatedSnapshot.exists) {
      // Firebaseから取得したデータをMap<String, dynamic>に変換
      Map<String, dynamic> data = Map<String, dynamic>.from(updatedSnapshot.value as Map).cast<String, dynamic>();

      // パズルのIDを取得（共有コードに一致する最初のパズルのID）
      String puzzleId = updatedSnapshot.key!;
      // FirebasePuzzle.fromJsonを呼び出して、FirebasePuzzleオブジェクトを作成
      // 更新されたデータをFirebasePuzzleオブジェクトに変換して返す
      return FirebasePuzzle.fromJson(puzzleId, data);
    } else {
      return null;
    }
  }

  Future<bool> checkRecordExistsBySharedCord(String sharedCode) async {
    Query sharedCodeQuery = _ref.orderByChild("sharedCode").equalTo(sharedCode);
    DataSnapshot sharedCodeSnapshot = (await sharedCodeQuery.once()).snapshot; // キャスト修正

    // DB内に同じ共有コードが存在したらtrueを返す
    return sharedCodeSnapshot.value != null;
  }





  Future<FirebasePuzzle?> checkRecordExistsAndGetData(List<List<int>> grid) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("firebasePuzzles");

    String encodedGrid = json.encode(grid);

    Query gridQuery = ref.orderByChild("grid").equalTo(encodedGrid);
    DatabaseEvent gridEvent = await gridQuery.once();
    if (gridEvent.snapshot.exists) {
      // Firebaseから取得したデータをMap<String, dynamic>に変換
      Map<String, dynamic> data = Map<String, dynamic>.from(gridEvent.snapshot.value as Map).cast<String, dynamic>();

      // パズルのIDを取得（共有コードに一致する最初のパズルのID）
      String puzzleId = data.keys.first;

      // パズルデータを取得
      Map<String, dynamic> puzzleData = data[puzzleId] as Map<String, dynamic>;

      // FirebasePuzzle.fromJsonを呼び出して、FirebasePuzzleオブジェクトを作成
      return FirebasePuzzle.fromJson(puzzleId, puzzleData);
    } 
    return null;
  }

  Future<List<FirebasePuzzle>> getTopCompletedPuzzles(int limit) async {
    Query query = _ref.orderByChild("completedPlayer").limitToLast(limit);

    DataSnapshot snapshot = await query.once() as DataSnapshot;
    if (snapshot.value != null) {
      // Map<Object?, Object?> を Map<String, dynamic> に安全にキャスト
      Map<String, dynamic> puzzleMap = (snapshot.value as Map).cast<String, dynamic>();

      List<FirebasePuzzle> puzzles = [];
      puzzleMap.forEach((key, value) {
        // value を Map<String, dynamic> にキャスト
        var puzzleData = value as Map<String, dynamic>;
        var puzzle = FirebasePuzzle.fromJson(key, puzzleData);
        puzzles.add(puzzle);
      });

      // 完了したプレイヤーの数に基づいてパズルをソート
      puzzles.sort((a, b) => b.completedPlayer.compareTo(a.completedPlayer));

      return puzzles;
    } else {
      return [];
    }
  }

  Future<List<FirebasePuzzle>> getTopPlayerPuzzles(int limit) async {
    Query query = _ref.orderByChild("numberOfPlayer").limitToLast(limit);

    DataSnapshot snapshot = await query.once() as DataSnapshot;
    if (snapshot.value != null) {
      // Map<Object?, Object?> を Map<String, dynamic> に安全にキャスト
      Map<String, dynamic> puzzleMap = (snapshot.value as Map).cast<String, dynamic>();

      List<FirebasePuzzle> puzzles = [];
      puzzleMap.forEach((key, value) {
        // value を Map<String, dynamic> にキャスト
        var puzzleData = value as Map<String, dynamic>;
        var puzzle = FirebasePuzzle.fromJson(key, puzzleData);
        puzzles.add(puzzle);
      });

      puzzles.sort((a, b) => b.numberOfPlayer.compareTo(a.numberOfPlayer));
      return puzzles;
    } else {
      return [];
    }
  }
}
