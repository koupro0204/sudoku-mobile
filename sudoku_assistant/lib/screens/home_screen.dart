import 'package:flutter/material.dart';
import 'package:sudoku_assistant/widgets/quick_access_widget.dart';
import 'package:sudoku_assistant/models/puzzle.dart';  // Import the puzzle model
import 'package:sudoku_assistant/screens/create_puzzle_screen.dart';  // Import the create puzzle screen
import 'package:sudoku_assistant/screens/puzzle_library_screen.dart'; 

class HomeScreen extends StatelessWidget {
  final Puzzle? lastPlayedPuzzle;  // This can be null if no puzzle was played before

  HomeScreen({this.lastPlayedPuzzle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sudoku Assistant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the last played puzzle if it exists
            if (lastPlayedPuzzle != null) 
              QuickAccessWidget(lastPlayedPuzzle: lastPlayedPuzzle!),
            
            SizedBox(height: 20),  // Spacer for better layout
            
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreatePuzzleScreen()),
                );
              },
              child: Text('Create Puzzle'),
            ),
            
            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                // Navigate to the Puzzle Library screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PuzzleLibraryScreen()),
                );
              },
              child: Text('Puzzle Library'),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                // Navigate to the Enter Shared Code screen
              },
              child: Text('Enter Shared Code'),
            ),
          ],
        ),
      ),
    );
  }
}
