import 'package:flutter/material.dart';
import 'dart:math';
import 'package:sudoku_assistant/services/firebase_service.dart';
import 'package:sudoku_assistant/models/firebase_puzzle.dart';
import 'package:sudoku_assistant/models/puzzle.dart';
import 'package:sudoku_assistant/services/local_storage_service.dart';

class FirebasePuzzleController {
  ValueNotifier<List<FirebasePuzzle>> firebasePuzzles = ValueNotifier([]);
  ValueNotifier<String?> errorNotifier = ValueNotifier<String?>(null);
  ValueNotifier<bool> isSaveNotifier = ValueNotifier<bool>(false);
  ValueNotifier<FirebasePuzzle?> firebasePuzzleNotifier = ValueNotifier<FirebasePuzzle?>(null);
  final FirebasePuzzleService _firebasePuzzleService = FirebasePuzzleService();
  LocalStorageService localStorageService = LocalStorageService();

  Future<void> deleteRanking() async {
    await localStorageService.deleteFirebaseDatas("newest_firebase_data");
    await localStorageService.deleteFirebaseDatas("completed_firebase_data");
    await localStorageService.deleteFirebaseDatas("number_firebase_data");
    // 他の2つも消す。
  }
  Future<void> updatePuzzleIdOnRanking(FirebasePuzzle firebasePuzzle, int puzzleId) async {
    await localStorageService.updateIdentityData("newest_firebase_data", firebasePuzzle, puzzleId);
    await localStorageService.updateIdentityData("completed_firebase_data", firebasePuzzle, puzzleId);
    await localStorageService.updateIdentityData("number_firebase_data", firebasePuzzle, puzzleId);
  }

  Future<List<FirebasePuzzle>> loadNewestPuzzles(int limit) async {
    try {
      List<FirebasePuzzle> firebasePuzzles = await localStorageService.getFirebaseDatas("newest_firebase_data");
      if (firebasePuzzles.isNotEmpty) {
        return firebasePuzzles;
      }else {
        firebasePuzzles = await _firebasePuzzleService.getNewestPuzzles(limit);
        List<Puzzle> localSharedPuzzles = await localStorageService.getSharedPuzzles();
        // ローカルの共有パズルをハッシュマップに変換
        var localPuzzlesMap = {for (var p in localSharedPuzzles) p.sharedCode: p};

        // Firebaseパズルの更新
        for (var firebasePuzzle in firebasePuzzles) {
          var localPuzzle = localPuzzlesMap[firebasePuzzle.sharedCode];
          if (localPuzzle != null) {
            firebasePuzzle.puzzleId = localPuzzle.id;
            firebasePuzzle.puzzle = localPuzzle;
          }
        }
        await localStorageService.insertFirebaseDatas(firebasePuzzles, "newest_firebase_data");
        return firebasePuzzles;
      }
    } catch (e) {
      // エラー処理
      errorNotifier.value = "エラーが発生しました: $e";
      print("error: $e");
      return [];
    }
  }
  Future<List<FirebasePuzzle>> loadNumberOfPlayerPuzzles(int limit) async {
    try {
      List<FirebasePuzzle> firebasePuzzles = await localStorageService.getFirebaseDatas("number_firebase_data");
      if (firebasePuzzles.isNotEmpty) {
        return firebasePuzzles;
      }else {
        firebasePuzzles = await _firebasePuzzleService.getNumnerOfPlayerPuzzles(limit);
        List<Puzzle> localSharedPuzzles = await localStorageService.getSharedPuzzles();
        // ローカルの共有パズルをハッシュマップに変換
        var localPuzzlesMap = {for (var p in localSharedPuzzles) p.sharedCode: p};

        // Firebaseパズルの更新
        for (var firebasePuzzle in firebasePuzzles) {
          var localPuzzle = localPuzzlesMap[firebasePuzzle.sharedCode];
          if (localPuzzle != null) {
            firebasePuzzle.puzzleId = localPuzzle.id;
            firebasePuzzle.puzzle = localPuzzle;
          }
        }
        await localStorageService.insertFirebaseDatas(firebasePuzzles, "number_firebase_data");
        return firebasePuzzles;
      }
    } catch (e) {
      // エラー処理
      errorNotifier.value = "エラーが発生しました: $e";
      return [];
    }
  }
  Future<List<FirebasePuzzle>> loadTopCompletedPuzzles(int limit) async {
    try {
      List<FirebasePuzzle> firebasePuzzles = await localStorageService.getFirebaseDatas("completed_firebase_data");
      if (firebasePuzzles.isNotEmpty) {
        return firebasePuzzles;
      }else {
        firebasePuzzles = await _firebasePuzzleService.getTopCompletedPuzzles(limit);
        List<Puzzle> localSharedPuzzles = await localStorageService.getSharedPuzzles();
        // ローカルの共有パズルをハッシュマップに変換
        var localPuzzlesMap = {for (var p in localSharedPuzzles) p.sharedCode: p};

        // Firebaseパズルの更新
        for (var firebasePuzzle in firebasePuzzles) {
          var localPuzzle = localPuzzlesMap[firebasePuzzle.sharedCode];
          if (localPuzzle != null) {
            firebasePuzzle.puzzleId = localPuzzle.id;
            firebasePuzzle.puzzle = localPuzzle;
          }
        }
        await localStorageService.insertFirebaseDatas(firebasePuzzles, "completed_firebase_data");
        return firebasePuzzles;
      }
    } catch (e) {
      // エラー処理
      errorNotifier.value = "エラーが発生しました: $e";
      return [];
    }
  }

  Future<void> loadGetPuzzleBySharedCord(String sharedCode) async {
      errorNotifier.value = null;
      isSaveNotifier.value = false;
      firebasePuzzleNotifier.value = null;
    // ローカルにsharedCodeを持っているものがあるときは、それを渡す。
    
    Puzzle? localPuzzle = await localStorageService.getPuzzleBySharedCord(sharedCode);
    if (localPuzzle != null) {
      firebasePuzzleNotifier.value = FirebasePuzzle(
        grid: localPuzzle.grid,
        name: localPuzzle.name,
        creationDate: localPuzzle.creationDate,
        completedPlayer: 1,
        numberOfPlayer: 1,
        sharedCode: sharedCode, // データから取得した共有コードに置き換える
      );
      errorNotifier.value = "既にデータがあります。";
      return;
    }
    var loadedPuzzle = await _firebasePuzzleService.getFirebasePuzzleBySharedCord(sharedCode);
    if (loadedPuzzle == null) {
      errorNotifier.value = "エラーが発生しました: データがありません。";
    }
    firebasePuzzleNotifier.value = loadedPuzzle;
  }

  Future<Puzzle?> addPuzzle(Puzzle puzzle) async {
    var sharedCode = generateRandomString(8);
    bool isCheck = await _firebasePuzzleService.checkRecordExistsBySharedCord(sharedCode);
    while (isCheck) {
      sharedCode = generateRandomString(8);
      isCheck = await _firebasePuzzleService.checkRecordExistsBySharedCord(sharedCode);
    }
    var firebasePuzzle = FirebasePuzzle(
      grid: puzzle.grid,
      name: puzzle.name,
      creationDate: puzzle.creationDate,
      completedPlayer: 1,
      numberOfPlayer: 1,
      sharedCode: sharedCode, // データから取得した共有コードに置き換える
    );
    try {
      await _firebasePuzzleService.addFirebasePuzzle(firebasePuzzle);
      Puzzle updatePuzzle = Puzzle(
        id: puzzle.id,
        grid: puzzle.grid,
        name: puzzle.name,
        status: StatusNumber.shared,
        creationDate: puzzle.creationDate,
        sharedCode: sharedCode, // データから取得した共有コードに置き換える
        source: puzzle.source,
      );
      await localStorageService.updatePuzzle(updatePuzzle);
      await localStorageService.insertFirebaseData(firebasePuzzle);
      firebasePuzzleNotifier.value = firebasePuzzle;
      return updatePuzzle;
    } catch (e) {
      // エラー処理
      errorNotifier.value = "エラーが発生しました: $e";
      return null;
    }
  }
  Future<void> insertFirebasePuzzleForLocalOnRanking(FirebasePuzzle puzzle) async {
    Puzzle localPuzzle = Puzzle(
      grid: puzzle.grid,
      name: puzzle.name,
      status: StatusNumber.none,
      creationDate: puzzle.creationDate,
      sharedCode: puzzle.sharedCode, // データから取得した共有コードに置き換える
      source: SourceNumber.share,
    );

    int puzzleId = await localStorageService.insertPuzzle(localPuzzle);
    localPuzzle = localPuzzle.copyWith(id: puzzleId);
    FirebasePuzzle firebasePuzzle = FirebasePuzzle(
      firebaseId: puzzle.firebaseId,
      grid: puzzle.grid,
      name: puzzle.name,
      puzzleId: puzzleId,
      creationDate: puzzle.creationDate,
      puzzle: localPuzzle,
      completedPlayer: puzzle.completedPlayer,
      numberOfPlayer: puzzle.numberOfPlayer + 1,
      sharedCode: puzzle.sharedCode, // データから取得した共有コードに置き換える
    );
    await localStorageService.insertFirebaseData(firebasePuzzle);
    // 保存したら、FirebaseのデータのNumberOfPlayerを更新する
    await _firebasePuzzleService.updateNumberOfPlayer(firebasePuzzle);
    updatePuzzleIdOnRanking(firebasePuzzle, puzzleId);
  }
  Future<void> insertFirebasePuzzleForLocal(FirebasePuzzle puzzle) async {
    Puzzle localPuzzle = Puzzle(
      grid: puzzle.grid,
      name: puzzle.name,
      status: StatusNumber.none,
      creationDate: puzzle.creationDate,
      sharedCode: puzzle.sharedCode, // データから取得した共有コードに置き換える
      source: SourceNumber.share,
    );

    int puzzleId = await localStorageService.insertPuzzle(localPuzzle);
    localPuzzle = localPuzzle.copyWith(id: puzzleId);
    FirebasePuzzle firebasePuzzle = FirebasePuzzle(
      firebaseId: puzzle.firebaseId,
      grid: puzzle.grid,
      name: puzzle.name,
      puzzleId: puzzleId,
      creationDate: puzzle.creationDate,
      puzzle: localPuzzle,
      completedPlayer: puzzle.completedPlayer,
      numberOfPlayer: puzzle.numberOfPlayer + 1,
      sharedCode: puzzle.sharedCode, // データから取得した共有コードに置き換える
    );
    await localStorageService.insertFirebaseData(firebasePuzzle);
    // 保存したら、FirebaseのデータのNumberOfPlayerを更新する
    await _firebasePuzzleService.updateNumberOfPlayer(firebasePuzzle);
    isSaveNotifier.value = true;
    firebasePuzzleNotifier.value = firebasePuzzle;
  }

  Future<void> updateCompletedOfPlayer(String sharedCode) async {
    FirebasePuzzle? localFirebasePuzzle = await localStorageService.getFirebaseDataBySharedCord(sharedCode);
    if (localFirebasePuzzle == null) {
      errorNotifier.value = "エラーが発生しました: データがありません。";
      return;
    }
    try {
      FirebasePuzzle? updatedFirebasePuzzle =await _firebasePuzzleService.updateCompletedOfPlayer(localFirebasePuzzle);
      if (updatedFirebasePuzzle == null) {
        errorNotifier.value = "エラーが発生しました: データがありません。";
        return;
      }
      await localStorageService.updateFirebaseData(updatedFirebasePuzzle);
    } catch (e) {
      // エラー処理
      errorNotifier.value = "エラーが発生しました: $e";
    }

  }

  Future<void> updatePuzzle(FirebasePuzzle puzzle) async {
    try {
      await _firebasePuzzleService.updateFirebasePuzzle(puzzle);
    } catch (e) {
      // エラー処理
      errorNotifier.value = "エラーが発生しました: $e";
    }
  }

}
String generateRandomString(int length) {
  const String characters =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  Random random = Random();
  String result = "";

  for (int i = 0; i < length; i++) {
    result += characters[random.nextInt(characters.length)];
  }

  return result;
}