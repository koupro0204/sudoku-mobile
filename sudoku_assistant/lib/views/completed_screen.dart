import 'package:flutter/material.dart';
import 'package:sudoku_assistant/models/puzzle.dart';
import 'package:sudoku_assistant/widgets/preview.dart';
import 'package:sudoku_assistant/views/home_screen.dart';
class CompletedScreen extends StatefulWidget {
  final Puzzle puzzle;
  final PlayingData playingData;
  const CompletedScreen({
    super.key,
    required this.puzzle,
    required this.playingData,
    });

  @override
  CompletedScreenState createState() => CompletedScreenState();
}

class CompletedScreenState extends State<CompletedScreen> {
  
  @override
  void initState(){
    super.initState();

  }

// パズルの共有
// ホーム
// 完了時間

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.puzzle.name),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Completed'),
            Text(widget.puzzle.name),
            Text("クリアタイム"),
            Text("${(widget.playingData.elapsedTime ~/ 60).toString().padLeft(2, '0')}:${(widget.playingData.elapsedTime % 60).toString().padLeft(2, '0')}",),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: PreviewGrid(
                grid: widget.puzzle.grid,
                currentState: widget.playingData.currentGrid,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigator.pushReplacement(
                //   context, 
                //   MaterialPageRoute(
                //     builder: (context) => HomeScreen(),
                //   ),);
              },
              child: Text('share'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  ),);
              },
              child: Text('home'),
            ),
          ],
        ),
      ),
    );
  }

}