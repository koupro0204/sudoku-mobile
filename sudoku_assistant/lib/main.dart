import 'package:flutter/material.dart';
import 'package:sudoku_assistant/models/puzzle.dart';
import 'package:sudoku_assistant/screens/home_screen.dart';
import 'package:sudoku_assistant/screens/create_puzzle_screen.dart';
import 'package:sudoku_assistant/screens/puzzle_library_screen.dart';
import 'package:sudoku_assistant/screens/question_screen.dart';
import 'package:sudoku_assistant/screens/clear_screen.dart';

void main() {
  runApp(SudokuAssistantApp());
}

class SudokuAssistantApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku Assistant',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
      routes: {
        '/createPuzzleScreen': (context) => CreatePuzzleScreen(),
        '/puzzleLibraryScreen': (context) => PuzzleLibraryScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle routes dynamically
        if (settings.name == "/questionScreen") {
          final Puzzle puzzle = settings.arguments as Puzzle; // You'd pass this when navigating
          return MaterialPageRoute(builder: (context) => QuestionScreen(puzzle: puzzle));
        }
        if (settings.name == "/clearScreen") {
          final Puzzle puzzle = settings.arguments as Puzzle;
          return MaterialPageRoute(builder: (context) => ClearScreen(puzzle: puzzle));
        }
        // For other routes, return null
        return null;
      },
    );
  }
}
