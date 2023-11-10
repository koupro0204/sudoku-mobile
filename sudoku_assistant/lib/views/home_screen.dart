import 'package:flutter/material.dart';
import 'package:sudoku_assistant/models/puzzle.dart';
import 'package:sudoku_assistant/services/local_storage_service.dart';
import 'package:sudoku_assistant/views/create_puzzle_screen.dart';
import 'package:sudoku_assistant/views/library_screen.dart';
// import 'package:sudoku_assistant/widgets/puzzle_thumbnail.dart'; 
import 'package:sudoku_assistant/widgets/preview.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
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
        lastPlayedPuzzle = Puzzle.fromMap(puzzles.first.toMap());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPuzzleAvailable = lastPlayedPuzzle != null;
    final lastPuzzleGrid = isLastPuzzleAvailable ? lastPlayedPuzzle!.grid : [[0]];
    final lastPuzzleCurrentState = isLastPuzzleAvailable ? lastPlayedPuzzle!.currentState : [[0]];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku Assistant'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (isLastPuzzleAvailable) ...[
              Text(lastPlayedPuzzle!.name),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7, // 画面の横幅の85%に設定
                child: PreviewGrid(
                  grid: lastPuzzleGrid,
                  currentState: lastPuzzleCurrentState,
                  ), // lastPuzzleGridは前回保存されたパズルのグリッドデータ
              ),
              const SizedBox(height: 20), // ボタンとの間隔
              ElevatedButton(
                onPressed: () {
                  // Navigate to the Play Puzzle Screen
                },
                child: const Text('Play This Puzzle'),
              ),
            ],
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PuzzleLibraryScreen(),
                  ),
                );
              },
              child: const Text('Puzzle Library'),
            ),
            ElevatedButton(
              onPressed: () {
                // indicate widget for entering shared code
                // or
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
