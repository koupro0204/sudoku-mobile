import 'package:flutter/material.dart';
import 'dart:math';
import 'package:sudoku_assistant/models/puzzle.dart';  // Import the puzzle model
import 'package:sudoku_assistant/widgets/sudoku_grid_widget.dart';
import 'package:sudoku_assistant/widgets/number_button_widget.dart';
import 'package:sudoku_assistant/widgets/control_button_widget.dart';
import 'package:sudoku_assistant/widgets/top_bar_widget.dart';

class QuestionScreen extends StatefulWidget {
  final Puzzle puzzle; // Assuming you're passing the puzzle data to this screen

  QuestionScreen({required this.puzzle});

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
    bool isFixedNumberMode = false; // Initial mode is Direct Input
    Point<int>? selectedCell; // Will represent the currently selected cell (row, col)
    bool isNoteMode = false; // To determine if we are in note mode or number input mode
    Color currentNoteColor = Colors.blue; // Starting note color
    List<Color> noteColors = [Colors.blue, Colors.red, Colors.green]; // Available note colors for simplicity
    int? selectedRow;
    int? selectedCol;
    List<List<List<int>>> notesGrid = List.generate(9, (i) => List.generate(9, (j) => <int>[]));

    void _handleClearNotes() {
      if (selectedRow != null && selectedCol != null) {
          setState(() {
            notesGrid[selectedRow!][selectedCol!].clear(); // Clear the notes for the selected cell
          });
      }
    }


    void _handleToggleNotes() {
      setState(() {
          isNoteMode = !isNoteMode;
      });
    }

    void _handleChangeNoteColor() {
      setState(() {
          int currentIndex = noteColors.indexOf(currentNoteColor);
          currentNoteColor = noteColors[(currentIndex + 1) % noteColors.length];
      });
    }

    void _handleUndo() {
      // This is a stub. Implementing a full undo function requires tracking all moves, which is more complex.
      print("Undo the last move");
    }

    void _handleNumberSelected(int number) {
      if (isFixedNumberMode) {
          print('Highlight all instances of number $number');
      } else {
          if (selectedRow != null && selectedCol != null) {
              setState(() {
                  widget.puzzle.currentState[selectedRow!][selectedCol!] = number;
              });
          }
      }
    }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sudoku Puzzle'),
      ),
      body: Column(
        children: [
          TopBarWidget(puzzleName: widget.puzzle.name), // Display the puzzle name and timer
          Expanded(child: SudokuGridWidget(
              puzzle: widget.puzzle,
              onCellSelected: (int row, int col) {
                  setState(() {
                    selectedRow = row;
                    selectedCol = col;
                  });
              },
            )
          ),
          NumberButtonWidget(onNumberSelected: _handleNumberSelected), // Number buttons for input
          ControlButtonWidget(
            onClearNotes: _handleClearNotes,
            onToggleNotes: _handleToggleNotes,
            onChangeNoteColor: _handleChangeNoteColor,
            onUndo: _handleUndo,
          ), // Control buttons like erase, toggle notes, etc.
        ],
      ),
    );
  }
}
