import 'package:flutter/material.dart';
import 'package:sudoku_assistant/models/puzzle.dart';
import 'package:sudoku_assistant/services/puzzle_service.dart';
class PuzzleLibraryScreen extends StatefulWidget {
  @override
  _PuzzleLibraryScreenState createState() => _PuzzleLibraryScreenState();
}

class _PuzzleLibraryScreenState extends State<PuzzleLibraryScreen> {
  List<Puzzle> puzzles = []; // The list of puzzles to display.
  String filter = 'All';  // Default filter is 'All'.

  @override
  void initState() {
    super.initState();
    // Fetch puzzles from the database (or wherever they are stored).
    fetchPuzzles();
  }

  void fetchPuzzles() async {
      puzzles = await PuzzleService.getAllPuzzles();
      setState(() {}); // Refresh the UI after fetching the puzzles.
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Puzzle Library'),
        actions: [
          // Here, you can add filter dropdown or buttons to change the filter.
        ],
      ),
      body: ListView.builder(
        itemCount: puzzles.length,
        itemBuilder: (context, index) {
          final puzzle = puzzles[index];
          return ListTile(
            title: Text(puzzle.name),
            subtitle: Text(puzzle.creationDate.toString()),  // Format this date as per your requirements.
            trailing: Text(puzzle.status),
            onTap: () {
              // Here, navigate to the QuestionScreen or view more details about the puzzle.
            },
          );
        },
      ),
    );
  }
}
