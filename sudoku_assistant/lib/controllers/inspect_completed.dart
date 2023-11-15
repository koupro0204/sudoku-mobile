class Inspect {
  bool isCompleted = false;
  List<List<int>> grid;
  List<List<bool>> invalidCells;
  Inspect(this.grid,this.invalidCells);

  void updateGrid(List<List<int>> newGrid, List<List<bool>> newInvalidCells) {
    grid = newGrid;
    invalidCells = newInvalidCells;
  }
  bool inspectCompelted() {
    // バリデータを使用して、パズルが完了したかどうかを確認する
    // gridが完成しているかどうかを確認する
    // gridの中に0があるかどうかを確認する
    bool isContainsZero = grid.any((row) => row.any((cell) => cell == 0));
    bool isInvalid = invalidCells.any((row) => row.any((cell) => cell == true));

    if (!isContainsZero && !isInvalid) {
      isCompleted = true;
    }else{
      isCompleted = false;
    }
    return isCompleted;
  }
}