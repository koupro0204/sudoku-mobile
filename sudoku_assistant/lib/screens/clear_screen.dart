import 'package:flutter/material.dart';
import 'package:sudoku_assistant/models/puzzle.dart';

class ClearScreen extends StatefulWidget {
  final Puzzle puzzle;

  ClearScreen({required this.puzzle});

  @override
  _ClearScreenState createState() => _ClearScreenState();
}

class _ClearScreenState extends State<ClearScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Congratulations!',
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'You have completed the puzzle',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.normal,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _sharePuzzle,
              child: Text('Share Puzzle'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _sharePuzzle() {
    // Logic to share the puzzle.
    // This can involve generating a sharing code or directly sharing via other apps.
    // You mentioned Firebase earlier, so this could involve saving the puzzle to Firebase and generating a shareable link.
  }
}
