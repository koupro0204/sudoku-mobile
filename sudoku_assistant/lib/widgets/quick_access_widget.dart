import 'package:flutter/material.dart';
import 'package:sudoku_assistant/models/puzzle.dart';

class QuickAccessWidget extends StatelessWidget {
  final Puzzle lastPlayedPuzzle;

  QuickAccessWidget({required this.lastPlayedPuzzle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,  // Adjust dimensions as needed
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 9,
        ),
        itemBuilder: (context, index) {
          int row = index ~/ 9;
          int col = index % 9;
          int value = lastPlayedPuzzle.grid[row][col];

          return Center(
            child: Text(
              value == 0 ? '' : value.toString(),
              style: TextStyle(fontSize: 8),  // Small font size for the mini-grid
            ),
          );
        },
        itemCount: 81,
      ),
    );
  }
}
