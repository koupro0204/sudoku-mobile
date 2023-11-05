import 'package:flutter/material.dart';
import 'package:sudoku_assistant/widgets/number_button_bar.dart';
import 'package:sudoku_assistant/widgets/sudoku_grid.dart';
import 'package:sudoku_assistant/controllers/puzzle_controller.dart';
import 'package:sudoku_assistant/widgets/memo_buttun_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sudoku_assistant/widgets/save_button.dart';
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
    _puzzleController.setNumberLockState(isLocked);
    setState(() {});
  }
  void _handleReset() {
    _puzzleController.handleReset();
    setState(() {});
  }

  void _handleCellDelete() {
    _puzzleController.handleCellDelete();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double gridWidth = screenWidth * 0.98; // 98% of the screen width
    double gridMarginTop = MediaQuery.of(context).size.height * 0.01; // 1% of the screen height
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.generate_sudoku),
      ),
      body: Column(
        children: [
          SizedBox(height: gridMarginTop), // Add a margin at the top of the grid (optional
          Expanded(
            child: Center( // Center is added to center the Container
              child: SizedBox(
                width: gridWidth, // Set the width of the Container
                child: SudokuGrid(
                  onCellTap: _handleCellTap,
                  grid: _puzzleController.grid,
                  invalidCells: _puzzleController.invalidCells,
                  highlightedCells: _puzzleController.highlightedCells,
                  selectedcell: _puzzleController.selectedcell,
                  memoGrid: _puzzleController.memoGrid,
                ),
              ),
            ),
          ),
          SizedBox(height: gridMarginTop), // Add a margin at the top of the grid (optional
          MemoButtonBar(
            onCellDelete: _handleCellDelete,
          ),
          SizedBox(height: gridMarginTop), // Add a margin at the top of the grid (optional
          NumberButtonBar(
            onNumberTap: _handleNumberTap,
            onNumberLongPress: _handleNumberLongPress,
            onNumberLock: _handleNumberLock,
          ),
          SizedBox(height: gridMarginTop), // Add a margin at the top of the grid (optional
          SaveButtonBar(
            onReset: _handleReset,
          ),
          SizedBox(height: gridMarginTop), // Add a margin at the top of the grid (optional
          // Add Preview and Save button implementations here
        ],
      ),
    );
  }
}
