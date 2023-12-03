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


  Future<List<FirebasePuzzle>> loadNumnerOfPlayerPuzzles(int limit) async {
    try {
      var loadedPuzzles = await _firebasePuzzleService.getNumnerOfPlayerPuzzles(limit);
      return loadedPuzzles;
    } catch (e) {
      // エラー処理
      errorNotifier.value = "エラーが発生しました: $e";
      return [];
    }
  }
  Future<List<FirebasePuzzle>> loadNewestPuzzles(int limit) async {
    try {
      var loadedPuzzles = await _firebasePuzzleService.getNewestPuzzles(limit);
      return loadedPuzzles;
    } catch (e) {
      // エラー処理
      errorNotifier.value = "エラーが発生しました: $e";
      return [];
    }
  }
  Future<List<FirebasePuzzle>> loadTopCompletedPuzzles(int limit) async {
    try {
      var loadedPuzzles = await _firebasePuzzleService.getTopCompletedPuzzles(limit);
      firebasePuzzles.value = loadedPuzzles;
      return loadedPuzzles;
    } catch (e) {
      // エラー処理
      errorNotifier.value = "エラーが発生しました: $e";
      return [];
    }
  }
  // Future<void> loadGetPuzzleById(int puzzleId) async {
  //   try {
  //     var loadedPuzzle = await _firebasePuzzleService.getFirebasePuzzleById(puzzleId.toString());
  //     firebasePuzzleNotifier.value = loadedPuzzle;
  //   } catch (e) {
  //     // エラー処理
  //     errorNotifier.value = "エラーが発生しました: $e";
  //   }
  // }
  Future<void> loadGetPuzzleBySharedCord(String sharedCode) async {
      errorNotifier.value = null;
      isSaveNotifier.value = false;
      firebasePuzzleNotifier.value = null;
    // ローカルにsharedCodeを持っているものがあるときは、それを渡す。
    LocalStorageService localStorageService = LocalStorageService();
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
      LocalStorageService localStorageService = LocalStorageService();
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
  Future<void> insertFirebasePuzzleForLocal(FirebasePuzzle puzzle) async {
    LocalStorageService localStorageService = LocalStorageService();
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
    bool isCommitted = await _firebasePuzzleService.updateNumberOfPlayer(firebasePuzzle);
    // if (!isCommitted) {
    //    await _firebasePuzzleService.updateNumberOfPlayer(firebasePuzzle);
    //   return;
    // }
    isSaveNotifier.value = true;

    firebasePuzzleNotifier.value = firebasePuzzle;
  }

  Future<void> updateCompletedOfPlayer(String sharedCode) async {
    LocalStorageService localStorageService = LocalStorageService();
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