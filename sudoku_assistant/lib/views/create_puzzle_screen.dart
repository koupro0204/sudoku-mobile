import 'package:flutter/material.dart';
import 'package:sudoku_assistant/widgets/number_button_bar.dart';
import 'package:sudoku_assistant/widgets/sudoku_grid.dart';
import 'package:sudoku_assistant/controllers/puzzle_controller.dart';

class CreatePuzzleScreen extends StatefulWidget {
  const CreatePuzzleScreen({super.key});

  @override
  _CreatePuzzleScreenState createState() => _CreatePuzzleScreenState();
}

class _CreatePuzzleScreenState extends State<CreatePuzzleScreen> {
  final PuzzleController _puzzleController = PuzzleController();

  void _handleCellTap(int x, int y) {
    _puzzleController.handleCellTap(x, y);
    setState(() {}); // Refresh the UI with the updated grid state
    
    // if (_puzzleController.selectedNumber != null) {
    //   // Apply the selected number to the tapped cell
    //   _puzzleController.handleNumberInput(x, y);
    //   setState(() {}); // Refresh the UI with the updated grid state
    // }else {
    //   // Open a number selection interface
    //   _puzzleController.handleCellTap(x, y);
    // }
  }

  void _handleNumberTap(int number) {
    // Set the selected number in the controller
    // If a cell was previously selected, apply the number to that cell
    if (_puzzleController.selectedRow != null && _puzzleController.selectedCol != null) {
      _puzzleController.selectedNumber = number;
      _puzzleController.handleNumberInput(_puzzleController.selectedRow!, _puzzleController.selectedCol!);
    }
      _puzzleController.selectedNumber = null;

    setState(() {});
  }
  void _handleNumberLongPress(int number) {
    _puzzleController.selectedNumber = number;
    _puzzleController.handleFixedMode(number);
    setState(() {});
  }

  void _handleNumberLock(bool isLocked) {
    // Lock or unlock the selected number
    if (!isLocked) {
      _puzzleController.selectedNumber = null;
    }
    _puzzleController.isNumberLocked = isLocked;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double gridWidth = screenWidth * 0.98; // 98% of the screen width
    double gridMarginTop = MediaQuery.of(context).size.height * 0.01; // 1% of the screen height
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Sudoku Puzzle'),
      ),
    body: Column(
      children: [
        SizedBox(height: gridMarginTop), // Add a margin at the top of the grid (optional
        Expanded(
          child: Center( // Center is added to center the Container
            child: Container(
              width: gridWidth, // Set the width of the Container
              child: SudokuGrid(
                onCellTap: _handleCellTap,
                grid: _puzzleController.grid,
                invalidCells: _puzzleController.invalidCells,
                highlightedCells: _puzzleController.highlightedCells,
                selectedcell: _puzzleController.selectedcell,
              ),
            ),
          ),
        ),
          NumberButtonBar(
            onNumberTap: _handleNumberTap,
            onNumberLongPress: _handleNumberLongPress,
            onNumberLock: _handleNumberLock,
          ),
          // Add Preview and Save button implementations here
        ],
      ),
    );
  }
}
