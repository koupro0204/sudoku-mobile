import 'package:flutter/material.dart';
import 'package:sudoku_assistant/models/puzzle.dart';
import 'package:sudoku_assistant/services/local_storage_service.dart';
import 'package:sudoku_assistant/views/create_puzzle_screen.dart';
import 'package:sudoku_assistant/views/play_screen.dart';
import 'package:sudoku_assistant/views/share_code_screen.dart';
import 'package:sudoku_assistant/widgets/preview.dart';
import 'package:sudoku_assistant/widgets/bottomNavigationbar.dart';
import 'package:sudoku_assistant/widgets/bannerAds.dart';
import 'package:sudoku_assistant/controllers/rewarded_ad_manager.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Puzzle? lastPlayedPuzzle;
  final RewardedAdManager rewardedAdManager = RewardedAdManager();

  Future<Puzzle?> _fetchLastPlayedPuzzle() async {
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
    rewardedAdManager.loadRewardedAd('ca-app-pub-3940256099942544/5224354917'); // テスト用の広告ユニットID
    // rewardedAdManager.loadRewardedAd('ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy'); // あなたの広告ユニットIDを指定
  }
  // ScaffoldのBottomNavigationBarで、top, ranking, library
  // ranking tab --> tabbarviewで、completedPlayer, numberOfPlayer
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku Assistant'),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomBottomNavigationBar(currentIndex: 0),
          BannerAdWidget(adUnitId: "ca-app-pub-3940256099942544/6300978111"), // テスト用の広告ユニットID
        ],
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
                            "last played puzzle",
                            style: TextStyle(
                              fontSize: 18.0,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 5.0),
                          child: Text(
                            "puzzle name: ${snapshot.data!.name}",
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
                          rewardedAdManager.showRewardedAd();
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
                      // ElevatedButton(
                      //   onPressed: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => PuzzleLibraryScreen(),
                      //       ),
                      //     );
                      //   },
                      //   child: const Text('Puzzle Library'),
                      // ),
                      ElevatedButton(
                        onPressed: () {
                          // indicate widget for entering shared code
                          // or
                          // Navigate to the Enter Shared Code Screen
                          // text box dialog
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EnterSharedCodeScreen(),
                            ),
                          );

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
