import 'package:flutter/material.dart';
import 'package:sudoku_assistant/models/puzzle.dart';
import 'package:sudoku_assistant/services/local_storage_service.dart';
import 'package:sudoku_assistant/views/create_puzzle_screen.dart';
import 'package:sudoku_assistant/views/library_screen.dart';
import 'package:sudoku_assistant/views/play_screen.dart';
import 'package:sudoku_assistant/widgets/preview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Puzzle? lastPlayedPuzzle;

  Future<Puzzle?> _fetchLastPlayedPuzzle() async {
    // 従来のコード
    // var puzzles = await LocalStorageService().getPuzzles();
    // if (puzzles.isNotEmpty) {
    //   puzzles.sort((a, b) => b.creationDate.compareTo(a.creationDate));
    //   final lastPlayedPuzzle = Puzzle.fromMap(puzzles.first.toMap());
    //   final playingData =
    //       await LocalStorageService().getPlayingDataByPuzzleId(lastPlayedPuzzle.id!);
    //   if (playingData.isNotEmpty) {
    //     playingData.sort((a, b) => b.id!.compareTo(a.id!));
    //     lastPlayedPuzzle.setPlayingData(playingData.first);
    //   } else {
    //     lastPlayedPuzzle.setPlayingData(
    //       PlayingData(
    //         id: null,
    //         currentGrid: List.generate(9, (_) => List.filled(9, 0)),
    //       ),
    //     );
    //   }
    //   return lastPlayedPuzzle;
    // } else {
    //   return null;
    // }
    var playingDatas = await LocalStorageService().getPlayingDataIsPlaying();
    if (playingDatas.isNotEmpty) {
      playingDatas.sort((a, b) => b.id!.compareTo(a.id!));
      final lastPlayedPlayingData = PlayingData.fromMap(playingDatas.first.toMap());
      final lastPlayedPuzzle =
          await LocalStorageService().getPuzzleById(lastPlayedPlayingData.puzzleId!);
      lastPlayedPuzzle.setPlayingData(lastPlayedPlayingData);

      return lastPlayedPuzzle;
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
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
            FutureBuilder<Puzzle?>(
              future: _fetchLastPlayedPuzzle(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final isLastPuzzleAvailable = snapshot.data != null;
                  final lastPuzzleGrid =
                      isLastPuzzleAvailable ? snapshot.data!.grid : [[0]];
                  final lastPuzzleCurrentState =
                      isLastPuzzleAvailable ? snapshot.data!.playingData!.currentGrid : [[0]];

                  return Column(
                    children: <Widget>[
                      if (isLastPuzzleAvailable) ...[
                        Padding(
                          padding: EdgeInsets.only(bottom: 5.0),
                          child: Text(
                            snapshot.data!.name,
                            style: TextStyle(
                              fontSize: 18.0,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: PreviewGrid(
                            grid: lastPuzzleGrid,
                            currentState: lastPuzzleCurrentState,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PlayPuzzleScreen(puzzle: snapshot.data!, playingData: snapshot.data!.playingData!),
                              ),
                            );
                          },
                          child: const Text('Play This Puzzle'),
                        ),
                      ],
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CreatePuzzleScreen(),
                            ),
                          );
                        },
                        child: const Text('Create Puzzle'),
                      ),
                      ElevatedButton(
                        onPressed: () {
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
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
