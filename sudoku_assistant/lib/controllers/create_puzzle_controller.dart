import 'package:sudoku_assistant/controllers/highlight_manager.dart';
import 'package:sudoku_assistant/controllers/validator.dart';
import 'package:sudoku_assistant/controllers/action_manager.dart';

class CreatePuzzleController {
  List<List<int>> grid = List.generate(9, (_) => List.filled(9, 0));
  int? selectedNumber; // For Fixed Number Mode
  bool isNumberLocked = false; // To track if a number is locked
  // Track the last selected cell for Direct Input Mode
  int? selectedRow;
  int? selectedCol;

  // memo
  List<List<List<int>>> memoGrid = List.generate(9, (_) => List.generate(9, (_) => <int>[]));
  bool isMemoMode = false; // メモがオンかオフかを追跡するフラグ

  late Validator validator; // validator.dart
  late HighlightManager highlightManager; // highlight_manager.dart
  late ActionManager actionManager; // action_manager.dart

  // PuzzleControllerのコンストラクタ
  CreatePuzzleController() {
    validator = Validator(grid, memoGrid); // Validatorのインスタンスを初期化する
    highlightManager = HighlightManager(9); // HighlightManagerのインスタンスを初期化する
    actionManager = ActionManager(undoAction: undoAction); 
  }
  // PuzzleControllerからcreate_puzzle_screen.dartに返す値を定義する
  List<List<bool>> get highlightedCells => highlightManager.getHighlightedCells();
  List<List<bool>> get selectedCell => highlightManager.getSelectedCells();
  List<List<bool>> get invalidCells => validator.getInvalidCells();

  bool maxNumber(int number) {
    Map<int, int> numberCount = {};
    for (var row in grid) {
      for (var number in row) {
        if (number != 0) { // 0 は無視する
          numberCount[number] = (numberCount[number] ?? 0) + 1;
        }
      }
    }
    if (numberCount[number] == 9) {
      return true;
    } else {
      return false;
    }
  }
  // Call this method when the locked state of a number changes
  void setNumberLockState(bool locked) {
    isNumberLocked = locked;
    if (!locked) {
      if (selectedRow != null && selectedCol != null) {
        handleCellTap(selectedRow!, selectedCol!);
      }
    }
  }
  // Call this method when the memo mode changes
  void setMemoMode(bool memoMode) {
    isMemoMode = memoMode;
  }

  void handleFixedMode(int number){
    highlightManager.resetHighlights();
    highlightManager.highlightSameNumbers(grid, number);
  }

  // Called when a cell is tapped
  void handleCellTap(int x, int y) {
    selectedRow = x;
    selectedCol = y;
    List<List<List<int>>> currentMemoGridCopy = memoGrid.map((row) => row.map((memo) => List<int>.from(memo)).toList()).toList();

    if (isNumberLocked && selectedNumber != null) {
      actionManager.addAction(PuzzleAction(
        x: x,
        y: y,
        oldValue: grid[x][y],
        memoGrid: currentMemoGridCopy,
      ));
      // In Fixed Number Mode, the selected number is already known
      if (isMemoMode){
        if (memoGrid[x][y].contains(selectedNumber)){
          memoGrid[x][y].remove(selectedNumber);
        } else{
          memoGrid[x][y].add(selectedNumber!);
          memoGrid[x][y].sort(); // sort numbers
        }
        grid[x][y] = 0; // Clear cell value
      } else{
        memoGrid[x][y] = <int>[]; // Clear memo
        grid[x][y] = selectedNumber!;
        // 新しい数字を入力した後に関連するセルからメモを削除
        validator.removeMemoFromRelatedCells(x, y, selectedNumber!);

        highlightManager.highlightSameNumbers(grid, selectedNumber!);
        validator.validate();
        if (maxNumber(selectedNumber!)) {
          // highlightManager.highlightSameNumbers(grid, selectedNumber!);
          // 入力された数字が9個になったらロック解除して0.0に持っていく。
          selectedNumber = null;
          isNumberLocked = false;
          highlightManager.resetHighlights();
          highlightManager.highlightAllRelatedCells(selectedRow!, selectedCol!, grid);          
        }
      }
    } else {
      // In Direct Input Mode, you would open a number selection interface
      highlightManager.highlightAllRelatedCells(x, y, grid);
    }
  }

  // Called when a cell is tapped in Fixed Number Mode
  void handleNumberInput(int x, int y) {
    selectedRow = x;
    selectedCol = y;
    List<List<List<int>>> currentMemoGridCopy = memoGrid.map((row) => row.map((memo) => List<int>.from(memo)).toList()).toList();
    actionManager.addAction(PuzzleAction(
      x: x,
      y: y,
      oldValue: grid[x][y],
      memoGrid: currentMemoGridCopy,
    ));
    if (isMemoMode){
      if (memoGrid[x][y].contains(selectedNumber)){
        memoGrid[x][y].remove(selectedNumber);
      } else{
        memoGrid[x][y].add(selectedNumber!);
        memoGrid[x][y].sort(); // sort numbers
      }
      grid[x][y] = 0; // Clear cell value
    } else{
      memoGrid[x][y] = <int>[]; // Clear memo
      grid[x][y] = selectedNumber!;
      // 新しい数字を入力した後に関連するセルからメモを削除
      validator.removeMemoFromRelatedCells(x, y, selectedNumber!);
      validator.validate();
      if (maxNumber(selectedNumber!)) {
        // 入力された数字が9個になったら
        selectedNumber = null;
        isNumberLocked = false;
        highlightManager.resetHighlights();
        highlightManager.highlightAllRelatedCells(selectedRow!, selectedCol!, grid);          
      }

    }
  }
  // Called when the reset button is tapped
  void handleReset(){
    actionManager.addAction(PuzzleAction(
      grid: grid,
      memoGrid: memoGrid,
    ));
    grid = List.generate(9, (_) => List.filled(9, 0));
    validator.updateGrid(grid, memoGrid);
    memoGrid = List.generate(9, (_) => List.generate(9, (_) => <int>[]));
    if (selectedNumber != null) {}
    selectedRow = 0;
    selectedCol = 0;
    highlightManager.resetHighlights();
  }

  // Called when the delete button is tapped
  void handleCellDelete() {
    if (selectedRow != null && selectedCol != null) {
      actionManager.addAction(PuzzleAction(
        x: selectedRow,
        y: selectedCol,
        oldValue: grid[selectedRow!][selectedCol!],
        memoList: memoGrid[selectedRow!][selectedCol!],
      ));
      grid[selectedRow!][selectedCol!] = 0;
      memoGrid[selectedRow!][selectedCol!] = <int>[]; // Clear memo
      validator.validate();
    }
  }
  // 状態を元に戻すメソッド
  void undoAction(PuzzleAction action) {
    // セルの値を復元する場合
    if (action.x != null && action.y != null && action.oldValue != null) {
      grid[action.x!][action.y!] = action.oldValue!;
      memoGrid[action.x!][action.y!] = <int>[]; // メモをクリア
    }
    // メモリストを復元する場合
    else if (action.x != null && action.y != null && action.memoList != null) {
      memoGrid[action.x!][action.y!] = List.from(action.memoList!);
      grid[action.x!][action.y!] = 0; // セルの値をクリア
    }
    
    // 全体のグリッド状態を復元する場合
    if (action.grid != null) {
      grid = List.generate(9, (i) => List.from(action.grid![i]));
    }

    // 全体のメモグリッド状態を復元する場合
    if (action.memoGrid != null) {
      memoGrid = List.generate(9, (i) => List.from(action.memoGrid![i]));
    }

    // バリデータとハイライトマネージャを更新
    validator.updateGrid(grid, memoGrid);
    if (action.x != null && action.y != null) {
      selectedRow = action.x;
      selectedCol = action.y;
    }
    validator.validate();
    if (isNumberLocked) {
      highlightManager.resetHighlights();
      highlightManager.highlightSameNumbers(grid, selectedNumber!);
    } else {
      highlightManager.highlightAllRelatedCells(selectedRow!, selectedCol!, grid);
    }
  }
}