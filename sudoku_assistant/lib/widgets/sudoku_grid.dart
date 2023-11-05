import 'package:flutter/material.dart';

class SudokuGrid extends StatelessWidget {
  final Function(int, int) onCellTap;
  final List<List<int>> grid;
  final List<List<bool>> invalidCells;
  final List<List<bool>> highlightedCells;
  final List<List<bool>> selectedcell;
  final List<List<List<int>>> memoGrid; // Add memoGrid to the constructor
  // Include highlightedCells in the constructor
  const SudokuGrid({
    super.key,
    required this.onCellTap,
    required this.grid,
    required this.invalidCells,
    required this.highlightedCells,
    required this.selectedcell,
    required this.memoGrid,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
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
        bool hasMemo = memo.isNotEmpty;


        // Update the color based on the highlighting
        Color? backgroundColor;
        if (isHighlighted) {
          backgroundColor = Colors.lightBlueAccent.withAlpha(50);
        }
        if (isSelected) {
          backgroundColor = Colors.blueAccent.withAlpha(80);
        }
        if (isInvalid) {
          backgroundColor = Colors.red.withAlpha(100);
        }
        
        // 境界線の太さを定義する
        final BorderSide normalSide = BorderSide(color: Colors.grey, width: 0.5);
        final BorderSide thickSide = BorderSide(color: Colors.black, width: 2);

        // 3x3ボックスの境界かどうかをチェック
        final bool isRightSide = y == 8; // 最後の列
        final bool isBottomSide = x == 8; // 最後の行
        final bool isLeftSide = y % 3 == 0 || y == 0; // 左のボックスの境界または最初の列
        final bool isTopSide = x % 3 == 0 || x == 0; // 上のボックスの境界または最初の行

        // メモのスタイルを定義する
        final TextStyle memoStyle = TextStyle(
          fontSize: 6,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        );

        // メインの数字のスタイルを定義する
        final TextStyle mainNumberStyle = TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isInvalid ? Colors.red : Colors.black,
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
                ? Container(
                  // 9等分されたグリッドを作成するための設定
                  child: GridView.count(
                    crossAxisCount: 3, // 3列
                    children: List.generate(9, (index) {
                      return Center(
                        child: Text(
                          memo.isNotEmpty && memo.length > index ? memo[index].toString() : '',
                          style: memoStyle,
                        ),
                      );
                    }),
                  ),
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
