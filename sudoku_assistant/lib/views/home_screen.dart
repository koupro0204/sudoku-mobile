import 'package:flutter/material.dart';
import 'package:sudoku_assistant/models/puzzle.dart';
import 'package:sudoku_assistant/services/local_storage_service.dart';
import 'package:sudoku_assistant/views/create_puzzle_screen.dart';
// import 'package:sudoku_assistant/widgets/puzzle_thumbnail.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Puzzle? lastPlayedPuzzle;

  @override
  void initState() {
    super.initState();
    _loadLastPlayedPuzzle();
  }

  Future<void> _loadLastPlayedPuzzle() async {
    // Assuming you have a method in LocalStorageService to get the last played puzzle
    var puzzles = await LocalStorageService().getPuzzles();
    if (puzzles.isNotEmpty) {
      // Sorting puzzles by last played date to get the most recent one
      puzzles.sort((a, b) => b.creationDate.compareTo(a.creationDate));
      setState(() {
        lastPlayedPuzzle = puzzles.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku Assistant'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // if (lastPlayedPuzzle != null)
            //   PuzzleThumbnail(puzzle: lastPlayedPuzzle!),
            // ElevatedButton(
            //   onPressed: () {
            //     // Navigate to the Create Puzzle Screen
            //   },
            //   child: Text('Create Puzzle'),
            // ),
            ElevatedButton(
              onPressed: () {
                // Navigate to the Create Puzzle Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreatePuzzleScreen(),
                  ),
                );
              },
              child: const Text('Create Puzzle'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to the Puzzle Library Screen
              },
              child: const Text('Puzzle Library'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to the Enter Shared Code Screen
              },
              child: const Text('Enter Shared Code'),
            ),
          ],
        ),
      ),
    );
  }
}
