// validator.dart
class Validator {
  List<List<int>> grid;
  List<List<List<int>>> memoGrid;
  List<List<bool>> invalidCells;
  final int gridSize;
  final int boxSize;

  Validator(this.grid,this.memoGrid)
      : gridSize = grid.length,
        boxSize = (grid.length ~/ 3).toInt(),
        invalidCells = List.generate(grid.length, (_) => List.filled(grid.length, false));

  // グリッド全体の検証を行う
  void validate() {
    _clearInvalidCells(); // まず全てのセルの状態をリセット

    // 各行、列、ボックスごとに検証
    for (int i = 0; i < gridSize; i++) {
      _validateRow(i);
      _validateColumn(i);
      _validateBox(i ~/ 3, i % 3);
    }
  }
  // 新しいグリッドでValidatorを更新するメソッド
  void updateGrid(List<List<int>> newGrid, List<List<List<int>>> newMemoGrid) {
    grid = newGrid;
    memoGrid = newMemoGrid;
    _clearInvalidCells(); // グリッドを更新するときにinvalidCellsもリセット
  }

  // 行の検証を行う
  void _validateRow(int row) {
    Map<int, List<List<int>>> occurrences = {};
    for (int col = 0; col < gridSize; col++) {
      int number = grid[row][col];
      
      if (number != 0) {
        occurrences.putIfAbsent(number, () => []).add([row, col]);
      }
    }
    _markInvalidCells(occurrences);
  }

  // 列の検証を行う
  void _validateColumn(int col) {
    Map<int, List<List<int>>> occurrences = {};
    for (int row = 0; row < gridSize; row++) {
      int number = grid[row][col];
      if (number != 0) {
        occurrences.putIfAbsent(number, () => []).add([row, col]);
      }
    }
    _markInvalidCells(occurrences);
  }

  // ボックスの検証を行う
  void _validateBox(int boxRow, int boxCol) {
    Map<int, List<List<int>>> occurrences = {};
    for (int row = 0; row < boxSize; row++) {
      for (int col = 0; col < boxSize; col++) {
        int rowIndex = boxRow * boxSize + row;
        int colIndex = boxCol * boxSize + col;
        int number = grid[rowIndex][colIndex];
        if (number != 0) {
          occurrences.putIfAbsent(number, () => []).add([rowIndex, colIndex]);
        }
      }
    }
    _markInvalidCells(occurrences);
  }

  // 無効なセルをマークする
  void _markInvalidCells(Map<int, List<List<int>>> occurrences) {
    for (var indices in occurrences.values) {
      if (indices.length > 1) { // 同じ数字が複数回出現する場合
        for (var position in indices) {
          int row = position[0];
          int col = position[1];
          invalidCells[row][col] = true; // そのセルを無効とマークする
        }
      }
    }
  }

  // 全てのセルの無効マークをクリアする
  void _clearInvalidCells() {
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        invalidCells[i][j] = false;
      }
    }
  }

  // 無効なセルを取得するためのgetter
  List<List<bool>> getInvalidCells() {
    return invalidCells;
  }

  // 指定された数字と関連する行、列、ボックスからメモを削除する
  void removeMemoFromRelatedCells(int inputRow, int inputCol, int number) {
    // 同じ行のメモを削除
    for (int col = 0; col < gridSize; col++) {
      memoGrid[inputRow][col].remove(number);
    }

    // 同じ列のメモを削除
    for (int row = 0; row < gridSize; row++) {
      memoGrid[row][inputCol].remove(number);
    }

    // 同じボックスのメモを削除
    int startBoxRow = (inputRow ~/ 3) * 3;
    int startBoxCol = (inputCol ~/ 3) * 3;
    for (int row = startBoxRow; row < startBoxRow + 3; row++) {
      for (int col = startBoxCol; col < startBoxCol + 3; col++) {
        memoGrid[row][col].remove(number);
      }
    }
  }

}
