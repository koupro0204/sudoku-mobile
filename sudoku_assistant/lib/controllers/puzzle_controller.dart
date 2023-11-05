class PuzzleController {
  List<List<int>> grid = List.generate(9, (_) => List.filled(9, 0));
  List<List<List<int>>> memoGrid = List.generate(9, (_) => List.generate(9, (_) => <int>[]));
  List<List<bool>> invalidCells = List.generate(9, (_) => List.filled(9, false));
  int? selectedNumber; // For Fixed Number Mode
  bool isNumberLocked = false; // To track if a number is locked
  // Track the last selected cell for Direct Input Mode
  int? selectedRow;
  int? selectedCol;
  // new properties for tracking highlights.
  int? highlightedRow;
  int? highlightedCol;
  List<List<bool>> highlightedCells = List.generate(9, (_) => List.filled(9, false));
  List<List<bool>> selectedcell = List.generate(9, (_) => List.filled(9, false));

  
  // Call this method when the locked state of a number changes
  void setNumberLockState(bool locked) {
    isNumberLocked = locked;
    if (!locked) {
      if (selectedRow != null && selectedCol != null) {
        handleCellTap(selectedRow!, selectedCol!);
      }
    }
  }

  void handleFixedMode(int number){
    _resetHighlightsAndSelectedcell();
    _highlightSameNumbers(number);
  }

  // Called when a cell is tapped
  void handleCellTap(int x, int y) {
    selectedRow = x;
    selectedCol = y;
    if (isNumberLocked && selectedNumber != null) {
      // In Fixed Number Mode, the selected number is already known
      grid[x][y] = selectedNumber!;
      validateGrid();
    } else {
      // In Direct Input Mode, you would open a number selection interface
      _resetHighlightsAndSelectedcell(); // Reset all highlights before setting new ones
      selectedcell[x][y] = true; // Highlight the selected cell
      _highlightRow(x);
      _highlightColumn(y);
      _highlightBox(x, y);
      _highlightSameNumbers(grid[x][y]);
    }
  }

  // Called when a cell is tapped in Fixed Number Mode
  void handleNumberInput(int x, int y) {
    selectedRow = x;
    selectedCol = y;
    grid[x][y] = selectedNumber ?? grid[x][y]; // Only change if a number is selected
    validateGrid();

  }
  // Called when the reset button is tapped
  void handleReset(){
    grid = List.generate(9, (_) => List.filled(9, 0));
    invalidCells = List.generate(9, (_) => List.filled(9, false));
    if (selectedNumber != null) {}
    selectedRow = null;
    selectedCol = null;
    highlightedRow = null;
    highlightedCol = null;
    _resetHighlightsAndSelectedcell();
  }

  // Called when the delete button is tapped
  void handleCellDelete() {
    if (selectedRow != null && selectedCol != null) {
      grid[selectedRow!][selectedCol!] = 0;
      validateGrid();
    };
  }

  /*
    ここからvalidateのコード
    パズルの入力に対して、行、列、ボックスの各セルに重複する数字がないかをチェックする
  */

  // Checks the entire grid for any conflicts
  void validateGrid() {
    // Clear previous invalid cell marks
    for (var i = 0; i < 9; i++) {
      for (var j = 0; j < 9; j++) {
        invalidCells[i][j] = false;
      }
    }

    // Validate rows, columns, and boxes
    for (var i = 0; i < 9; i++) {
      validateRow(i);
      validateColumn(i);
      validateBox(i ~/ 3, i % 3);
    }
  }

  // Validate a single row
  void validateRow(int row) {
    Map<int, List<int>> occurrences = {};
    for (var col = 0; col < 9; col++) {
      int number = grid[row][col];
      if (number != 0) {
        occurrences.putIfAbsent(number, () => []);
        occurrences[number]!.add(col);
      }
    }
    for (var indices in occurrences.values) {
      if (indices.length > 1) {
        for (var col in indices) {
          invalidCells[row][col] = true;
        }
      }
    }
  }

  // Validate a single column
  void validateColumn(int col) {
    Map<int, List<int>> occurrences = {};
    for (var row = 0; row < 9; row++) {
      int number = grid[row][col];
      if (number != 0) {
        occurrences.putIfAbsent(number, () => []);
        occurrences[number]!.add(row);
      }
    }
    for (var indices in occurrences.values) {
      if (indices.length > 1) {
        for (var row in indices) {
          invalidCells[row][col] = true;
        }
      }
    }
  }

  // Validate a 3x3 box
  void validateBox(int boxRow, int boxCol) {
    Map<int, List<List<int>>> occurrences = {};
    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 3; col++) {
        int actualRow = 3 * boxRow + row;
        int actualCol = 3 * boxCol + col;
        int number = grid[actualRow][actualCol];
        if (number != 0) {
          occurrences.putIfAbsent(number, () => []);
          occurrences[number]!.add([actualRow, actualCol]);
        }
      }
    }
    for (var cells in occurrences.values) {
      if (cells.length > 1) {
        for (var cell in cells) {
          invalidCells[cell[0]][cell[1]] = true;
        }
      }
    }
  }

  /* ここまでvalidateのコード */
  /* 
    ここからhightlightのコード
    セルをハイライトするためのコード
  */

  // Reset all highlights and selected cells
  void _resetHighlightsAndSelectedcell() {
    for (var i = 0; i < 9; i++) {
      for (var j = 0; j < 9; j++) {
        highlightedCells[i][j] = false;
        selectedcell[i][j] = false;
      }
    }
  }
  // Highlight a row
  void _highlightRow(int x) {
    for (int col = 0; col < 9; col++) {
      highlightedCells[x][col] = true;
    }
  }
  // Highlight a column
  void _highlightColumn(int y) {
    for (int row = 0; row < 9; row++) {
      highlightedCells[row][y] = true;
    }
  }
  // Highlight a 3x3 box
  void _highlightBox(int x, int y) {
    int boxStartRow = x - x % 3;
    int boxStartCol = y - y % 3;
    for (int row = boxStartRow; row < boxStartRow + 3; row++) {
      for (int col = boxStartCol; col < boxStartCol + 3; col++) {
        highlightedCells[row][col] = true;
      }
    }
  }
  // Highlight cells with the same number
  void _highlightSameNumbers(int number) {
    if (number == 0) return; // Don't highlight if the cell is empty
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (grid[row][col] == number) {
          // highlightedCells[row][col] = true;
          selectedcell[row][col] = true;
        }
      }
    }
  }
}