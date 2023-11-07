// highlight_manager.dart

import 'dart:math' as math;

class HighlightManager {
  List<List<bool>> highlightedCells;
  List<List<bool>> selectedCells;
  final int gridSize;
  final int boxSize;

  HighlightManager(this.gridSize)
      : highlightedCells = List.generate(gridSize, (_) => List.filled(gridSize, false)),
        selectedCells = List.generate(gridSize, (_) => List.filled(gridSize, false)),
        boxSize = math.sqrt(gridSize).toInt();

  // 全てのハイライトをリセットするメソッド
  void resetHighlights() {
    for (var i = 0; i < gridSize; i++) {
      for (var j = 0; j < gridSize; j++) {
        highlightedCells[i][j] = false;
        selectedCells[i][j] = false;
      }
    }
  }

  // 特定のセルをハイライトするメソッド
  void highlightCell(int row, int col) {
    // resetHighlights();
    selectedCells[row][col] = true;
  }

  // 指定した行をハイライトするメソッド
  void highlightRow(int row) {
    for (var col = 0; col < gridSize; col++) {
      highlightedCells[row][col] = true;
    }
  }

  // 指定した列をハイライトするメソッド
  void highlightColumn(int col) {
    for (var row = 0; row < gridSize; row++) {
      highlightedCells[row][col] = true;
    }
  }

  // 指定したボックスをハイライトするメソッド
  void highlightBox(int boxRow, int boxCol) {
    var startRow = boxRow * boxSize;
    var startCol = boxCol * boxSize;
    for (var row = startRow; row < startRow + boxSize; row++) {
      for (var col = startCol; col < startCol + boxSize; col++) {
        highlightedCells[row][col] = true;
      }
    }
  }

  // グリッド内の同じ数値を持つ全てのセルをハイライトするメソッド
  void highlightSameNumbers(List<List<int>> grid, int number) {
    if (number == 0) return; // Don't highlight if the cell is empty
    for (var row = 0; row < gridSize; row++) {
      for (var col = 0; col < gridSize; col++) {
        if (grid[row][col] == number) {
          highlightedCells[row][col] = true;
        }
      }
    }
  }

  // 選択されたセルと関連するすべてのセルをハイライトするメソッド
  // 動作を速くするために、小分けされたメソッドを使用せずに、
  // 関連する行、列、ボックス、同じ数値を持つセルのみをハイライトする
  void highlightAllRelatedCells(int x, int y, List<List<int>> grid) {
    int number = grid[x][y];
    int boxStartRow = x - x % boxSize;
    int boxStartCol = y - y % boxSize;

    resetHighlights(); // 最初に全てのハイライトをリセット

    // 関連する行、列、ボックス、同じ数値を持つセルをハイライト
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        // 選択されたセルをハイライト
        if (row == x && col == y) {
          selectedCells[row][col] = true;
        }

        // 選択された行または列をハイライト
        if (row == x || col == y) {
          highlightedCells[row][col] = true;
        }

        // 選択されたボックスをハイライト
        if (row >= boxStartRow && row < boxStartRow + boxSize &&
            col >= boxStartCol && col < boxStartCol + boxSize) {
          highlightedCells[row][col] = true;
        }

        // グリッド内の同じ数値を持つセルをハイライト
        if (grid[row][col] == number && number != 0) {
          highlightedCells[row][col] = true;
        }
      }
    }
  }

  // 選択されたセルを取得するメソッド
  List<List<bool>> getSelectedCells() {
    return selectedCells;
  }

  // ハイライトされたセルを取得するメソッド
  List<List<bool>> getHighlightedCells() {
    return highlightedCells;
  }
}
