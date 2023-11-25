// 共有コードを入力するのはwidgetでいいかな
// この画面では複数のコードを入力できるようにする
import 'package:flutter/material.dart';
import 'package:sudoku_assistant/models/puzzle.dart';
import 'package:sudoku_assistant/models/firebase_puzzle.dart';
import 'package:sudoku_assistant/views/play_screen.dart';
import 'package:sudoku_assistant/widgets/preview.dart';
import 'package:sudoku_assistant/services/firebase_service.dart';
import 'package:sudoku_assistant/controllers/firebase_puzzle_controller.dart';
import 'package:sudoku_assistant/widgets/bottomNavigationbar.dart';
import 'package:sudoku_assistant/widgets/bannerAds.dart';
class EnterSharedCodeScreen extends StatefulWidget {
  const EnterSharedCodeScreen({Key? key});

  @override
  EnterSharedCodeScreenState createState() => EnterSharedCodeScreenState();
}

class EnterSharedCodeScreenState extends State<EnterSharedCodeScreen> {
  Puzzle? getPuzzle;
  // TextEditingControllerのインスタンスを作成
  final TextEditingController _controller = TextEditingController();
  final FirebasePuzzleController firebasePuzzleController = FirebasePuzzleController(FirebasePuzzleService());
  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    // コントローラを破棄
    _controller.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Enter Shared Code'),
    ),
    bottomNavigationBar: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomBottomNavigationBar(currentIndex: 3),
        BannerAdWidget(adUnitId: "ca-app-pub-3940256099942544/6300978111"), // テスト用の広告ユニットID
      ],
    ),
    body: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () { 
        primaryFocus?.unfocus();
        print("unfocus");
      },
      child:
    Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ValueListenableBuilder<FirebasePuzzle?>(
              valueListenable: firebasePuzzleController.firebasePuzzleNotifier,
              builder: (context, firebasePuzzle, child) {
                if (firebasePuzzle != null) {
                  // FirebasePuzzleが存在する場合のウィジェットをここに記述
                  return Column(
                    children: [
                      Text("Puzzle loaded: ${firebasePuzzle.name} by ${firebasePuzzle.sharedCode}"),
                      PreviewGrid(grid: firebasePuzzle.grid, currentState: firebasePuzzle.grid),
                      ValueListenableBuilder<String?>(
                        valueListenable: firebasePuzzleController.errorNotifier,
                        builder: (context, error, child) {
                          if (error != null) {
                            // FirebasePuzzleが存在する場合のウィジェットをここに記述
                            return Text("Error: $error");
                          } else {
                            // errorがnullの場合のElevatedButtonを表示
                            return ValueListenableBuilder<bool>(
                                valueListenable: firebasePuzzleController.isSaveNotifier,
                                builder: (context, isSave, child) {
                                  if (isSave) {
                                    // 保存した後のウィジェットをここに記述
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        TextButton(
                                          child: Text("play"),
                                          onPressed: () {
                                            // 問題画面に遷移する
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(builder: (context) => PlayPuzzleScreen(
                                                puzzle: firebasePuzzle.puzzle!,
                                                playingData: PlayingData(
                                                  id: null,
                                                  currentGrid: firebasePuzzle.puzzle!.grid,
                                                  ),
                                                )
                                              ),
                                            );
                                          },
                                        )
                                      ],
                                    );
                                  } else {
                                    // errorがnullの場合のElevatedButtonを表示
                                    return ElevatedButton(
                                      onPressed: (){
                                          firebasePuzzleController.insertFirebasePuzzleForLocal(firebasePuzzle);
                                      },
                                      child: const Text('save to local storage')
                                    );
                                  }
                                },
                            );
                          }
                        },
                      ),
                    ],
                  );
                } else {
                  // FirebasePuzzleがnullの場合のウィジェットをここに記述
                  return Text("No puzzle loaded");
                }
              },
            ),
            TextField(
              controller: _controller,
              maxLength: 8,
              decoration: InputDecoration(
                hintText: 'Enter Shared Code',
                border: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // キーボードを閉じる
                FocusScope.of(context).unfocus();
                String sharedCode = _controller.text;
                if (sharedCode.isEmpty) {
                  return;
                }
                if (sharedCode.length != 8) {
                  firebasePuzzleController.errorNotifier.value = "Invalid shared code";
                  return;
                }
                firebasePuzzleController.loadGetPuzzleBySharedCord(sharedCode);
              },
              child: const Text('Get Puzzle'),
            ),

          ],
        ),
      ),
    )
    )
  );
}

}
