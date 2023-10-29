import 'package:flutter/material.dart';
import 'package:sudoku_assistant/models/puzzle.dart';

class SudokuGridWidget extends StatefulWidget {
  final Puzzle puzzle;
  final bool isCreationMode;
  // final ValueChanged<Point<int>> onCellSelected;  // New callback
  final Function(int, int) onCellSelected;
  SudokuGridWidget({
    required this.puzzle, 
    this.isCreationMode = false,
    required this.onCellSelected,
  });

  @override
  _SudokuGridWidgetState createState() => _SudokuGridWidgetState();
}

class _SudokuGridWidgetState extends State<SudokuGridWidget> {
  // late List<List<int>> _grid;
  int? selectedRow;
  int? selectedCol;

  @override
  void initState() {
    super.initState();
    // _grid = List.from(widget.puzzle.currentState);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 9,
        childAspectRatio: 1.0,
      ),
      itemCount: 81,
      itemBuilder: (context, index) {
        int row = index ~/ 9;
        int col = index % 9;
        Color cellColor = (row == selectedRow && col == selectedCol)
            ? Colors.lightBlueAccent
            : Colors.white;
        return GestureDetector(
          onTap: () {
            widget.onCellSelected(row, col); // Call the callback and pass the row and col
          },
          child: Container(
            color: cellColor,
            // ... (rest of the cell decoration and child)
          ),
        );
      },
    );
  }
    Future<int?> _showNumberPicker(BuildContext context) async {
    return await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Pick a number'),
          children: <Widget>[
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              children: List<Widget>.generate(10, (int index) {
                return ChoiceChip(
                  label: Text(index == 0 ? 'Erase' : index.toString()),
                  selected: false,
                  onSelected: (bool selected) {
                    Navigator.pop(context, index == 0 ? null : index);
                  },
                );
              }),
            ),
          ],
        );
      },
    );
  }
}