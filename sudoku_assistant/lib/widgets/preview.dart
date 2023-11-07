// preview.dart
import 'package:flutter/material.dart';

class PreviewGrid extends StatelessWidget {
  final List<List<int>> grid;

  PreviewGrid({required this.grid});

  @override
  Widget build(BuildContext context) {
    int cellCount = grid.length * grid[0].length;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: grid.length,
        childAspectRatio: 1.0,
      ),
      itemCount: cellCount,
      itemBuilder: (BuildContext context, int index) {
        int x = index ~/ grid.length;
        int y = index % grid.length;
        int number = grid[x][y];
        // 境界線の条件
        final BorderSide normalSide = BorderSide(color: Colors.grey.shade400, width: 0.2);
        final BorderSide thickSide = BorderSide(color: Colors.grey.shade800, width: 1.0);
        final bool isRightSide = y == 8;
        final bool isBottomSide = x == 8;
        final bool isLeftSide = y % 3 == 0 || y == 0;
        final bool isTopSide = x % 3 == 0 || x == 0;

        return Container(
          decoration: BoxDecoration(
            border: Border(
              top: isTopSide ? thickSide : normalSide,
              left: isLeftSide ? thickSide : normalSide,
              right: isRightSide ? thickSide : BorderSide.none,
              bottom: isBottomSide ? thickSide : BorderSide.none,
            ),
          ),
          child: Center(
            child: Text(
              number != 0 ? number.toString() : '',
              style: TextStyle(
                fontSize: 18, // プレビューサイズに適したフォントサイズ
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }
}
