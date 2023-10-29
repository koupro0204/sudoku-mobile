import 'package:flutter/material.dart';
import 'package:sudoku_assistant/widgets/sudoku_grid_widget.dart';
import 'package:sudoku_assistant/widgets/number_button_widget.dart';
import 'package:sudoku_assistant/models/puzzle.dart';

class CreatePuzzleScreen extends StatefulWidget {
  @override
  _CreatePuzzleScreenState createState() => _CreatePuzzleScreenState();
}

class _CreatePuzzleScreenState extends State<CreatePuzzleScreen> {
  late Puzzle puzzle;  // The puzzle being created

  @override
  void initState() {
    super.initState();
    puzzle = Puzzle.empty();  // Initializes a blank puzzle
  }
  void _onCellSelected(int row, int col) {
    // Handle the selected cell
    // Maybe show the number picker or perform other actions
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Puzzle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SudokuGridWidget(
                puzzle: puzzle,
                isCreationMode: true,
                onCellSelected: _onCellSelected,
              ),
            ),
            SizedBox(height: 10),
            NumberButtonWidget(
              onNumberSelected: (number) {
                // Handle number selection
              },
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle puzzle preview
                  },
                  child: Text('Preview'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle puzzle save
                  },
                  child: Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
