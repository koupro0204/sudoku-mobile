import 'package:flutter/material.dart';

class SudokuGrid extends StatelessWidget {
  // currentGridを追加
  final Function(int, int) onCellTap;
  final int? selectedNumber;
  final List<List<int>> grid;
  final List<List<int>>? initialGrid;
  final List<List<bool>> invalidCells;
  final List<List<bool>> highlightedCells;
  final List<List<bool>> selectedcell;
  final List<List<List<int>>> memoGrid;
  
  // Include highlightedCells in the constructor
  const SudokuGrid({
    super.key,
    required this.onCellTap,
    required this.selectedNumber,
    required this.grid,
    required this.invalidCells,
    required this.highlightedCells,
    required this.selectedcell,
    required this.memoGrid,
    this.initialGrid,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      // physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 9,
        childAspectRatio: 1.0, // Square cells
      ),
      itemCount: 81,
      itemBuilder: (BuildContext context, int index) {
        final int x = index ~/ 9; // Row number
        final int y = index % 9; // Column number
        final int number = grid[x][y];
        final bool isInvalid = invalidCells[x][y];
        final bool isHighlighted = highlightedCells[x][y];
        final bool isSelected = selectedcell[x][y];
        final List<int> memo = memoGrid[x][y];
        final int initialGridNumber = initialGrid?[x][y] ?? 0;
        bool isInitial = initialGridNumber != 0;
        bool hasMemo = memo.isNotEmpty;

        // Update the color based on the highlighting
        Color? backgroundColor;
        if (isHighlighted) {
          backgroundColor = Colors.blueAccent.withAlpha(50);
        }
        if (isInvalid) {
          backgroundColor = Colors.red.withAlpha(100);
        }
        if (isSelected) {
          backgroundColor = Colors.lightBlueAccent.withAlpha(70);
        }
        
        // 境界線の太さを定義する
        const BorderSide normalSide = BorderSide(color: Colors.grey, width: 0.5);
        const BorderSide thickSide = BorderSide(color: Colors.black, width: 1.5);

        // 3x3ボックスの境界かどうかをチェック
        final bool isRightSide = y == 8; // 最後の列
        final bool isBottomSide = x == 8; // 最後の行
        final bool isLeftSide = y % 3 == 0 || y == 0; // 左のボックスの境界または最初の列
        final bool isTopSide = x % 3 == 0 || x == 0; // 上のボックスの境界または最初の行

        // メモのスタイルを定義する
        const TextStyle memoStyle = TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        );


        // メインの数字のスタイルを定義する
        final TextStyle mainNumberStyle = TextStyle(
          fontSize: 30,
          // fontWeight: FontWeight.bold,
          fontWeight: FontWeight.w400,
          color: isInvalid ? Colors.red : isInitial? Colors.black: Colors.blue.shade800,
        );

        return GestureDetector(
          onTap: () => onCellTap(x, y),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(
                top: isTopSide ? thickSide : normalSide,
                left: isLeftSide ? thickSide : normalSide,
                right: isRightSide ? thickSide : BorderSide.none,
                bottom: isBottomSide ? thickSide : BorderSide.none,
              ),
            ),
            child: Center(
              child: hasMemo
                  // 9等分されたグリッドを作成するための設定
                ? GridView.count(
                    crossAxisCount: 3, // 3列
                    children: List.generate(9, (index) {
                      // index + 1 は、GridViewのセルの番号（1から始まる）
                      bool hasCurrentMemo = memo.contains(index + 1);
                      return Center(
                        child: Container(
                          color: hasCurrentMemo && selectedNumber == (index + 1) ? Colors.yellow : Colors.transparent,
                          child: Text(
                            hasCurrentMemo ? (index + 1).toString() : '',
                            style: memoStyle,
                          ),
                        ),
                      );
                    }),
                  )
                : Text(
                    number != 0 ? number.toString() : '',
                    style: mainNumberStyle,
                  ),
            ),
          ),
        );
      },
    );
  }
}
