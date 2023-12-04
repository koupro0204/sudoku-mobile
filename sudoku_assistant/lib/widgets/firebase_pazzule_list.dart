import 'package:flutter/material.dart';
import 'package:sudoku_assistant/models/firebase_puzzle.dart';
import 'package:sudoku_assistant/models/puzzle.dart';
import 'package:intl/intl.dart';
import 'package:sudoku_assistant/widgets/preview.dart';
import 'package:sudoku_assistant/views/play_screen.dart';
import 'package:sudoku_assistant/services/local_storage_service.dart';
class FirebasePuzzleEntry extends StatelessWidget {
  final FirebasePuzzle puzzle;
  final Function(int) onGetByPuzzuleId;
  final Function(FirebasePuzzle) onSaveButtonPressed;
  // final Function(Puzzle) onShare; // Callback for sharing the puzzle
  const FirebasePuzzleEntry({super.key,
    // required this.onShare,
    required this.puzzle,
    required this.onGetByPuzzuleId,
    required this.onSaveButtonPressed,
  });
  // _showPreviewDialogがポップアップとして表示されます。
  void _showPreviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<PlayingData>(
          future: onGetByPuzzuleId(puzzle.puzzle!.id!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // データの読み込み中に表示するウィジェットを返す
              return const CircularProgressIndicator(); // 例えば読み込み中のプログレスインジケータ
            } else if (snapshot.hasError) {
              // エラーが発生した場合に表示するウィジェットを返す
              return Text('Error: ${snapshot.error}');
            } else {
              // データの読み込みが成功した場合に表示するウィジェットを返す
              final playingData = snapshot.data;
              final isPlayingData = playingData!.id != null;
              return AlertDialog(
                title: Text(puzzle.name),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "share cord: "+puzzle.sharedCode,
                        style: const TextStyle(
                          fontSize: 16, 
                          color: Colors.black, // 色を少し薄くする
                        ),
                      ),
                      SizedBox(height: 16), // 余白を追加
                      Flexible(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: PreviewGrid(
                            grid: puzzle.grid,
                            currentState: playingData.currentGrid,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                actions: <Widget>[ 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        child: Text("close"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      isPlayingData ?
                      TextButton(
                        child: Text("restart"),
                        onPressed: () {
                          LocalStorageService().deletePlayingData(playingData.id!);
                          // 問題画面に遷移する
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => PlayPuzzleScreen(
                              puzzle: puzzle.puzzle!,
                              playingData: PlayingData(
                                id: null,
                                currentGrid: List.generate(9, (_) => List.filled(9, 0)),
                              )
                            )),
                          );
                        },
                      )
                      : Container(),
                      TextButton(
                        child: Text("play"),
                        onPressed: () {
                          // 問題画面に遷移する
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => PlayPuzzleScreen(puzzle: puzzle.puzzle!, playingData: playingData,)),
                          );
                        },
                      ),
                    ],
                  ),

                ],
              );
            }
          },
        );
      },
    );
  }

  // パズルのステータスに応じて適切なバッジを生成するメソッド
  Widget _buildStatusBadge() {
  TextStyle badgeTextStyle = TextStyle(color: Colors.white, fontSize: 12);
    String statusText;
    Color badgeColor;
    if (puzzle.puzzle != null){
      if (puzzle.puzzle!.status == StatusNumber.shared) {
        statusText = '共有中';
        badgeColor = Colors.deepPurpleAccent.shade400; // 共有中/クリア済みのバッジの色
      } else if (puzzle.puzzle!.status == StatusNumber.completed) {
        statusText = 'クリア済み';
        badgeColor = Colors.green; // クリア済みのバッジの色
      } else {
        statusText = '未完了';
        badgeColor = Colors.grey; // 未完了のバッジの色
      }
    } else {
      // return Container();
        statusText = '未取得';
        badgeColor = Colors.white; // 未完了のバッジの色
        badgeTextStyle = TextStyle(color: Colors.red.shade200, fontSize: 12);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        statusText,
        style: badgeTextStyle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGet = puzzle.puzzle != null;
    return ListTile(
      onTap: () {
        // パズルの詳細画面に遷移するコードをここに追加
        isGet ?_showPreviewDialog(context) :onSaveButtonPressed(puzzle);
      },
      title: Padding(
        padding: EdgeInsets.symmetric(vertical: 8), // タイトル周辺のパディングを追加
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // _buildSourceBadge(),
                    _buildStatusBadge(),
                  ],
                ),
                const SizedBox(width: 8), // バッジと名前の間のスペースを増やす
                Expanded( // テキストがオーバーフローしないようにする
                  child: Text(
                    puzzle.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, // 名前のフォントウェイトを変更
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4), // 追加のスペース
            Text(
              '${puzzle.completedPlayer}/${puzzle.numberOfPlayer}人がクリア済み',
              style: const TextStyle(
                fontSize: 16, 
              ),
            ),
            Text(
              'Created on ${DateFormat('yyyy-MM-dd HH:mm').format(puzzle.creationDate)}',
              style: const TextStyle(
                fontSize: 12, 
                color: Colors.grey, // 色を少し薄くする
              ),
            ),
          ],
        ),
      ),
      trailing: ElevatedButton(
        onPressed: () {
          isGet ?_showPreviewDialog(context) :onSaveButtonPressed(puzzle);
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
            isGet ? Colors.blue : Colors.greenAccent.shade700, // 背景色の調整
          ),
          padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(10)), // ボタンのパディングを追加
        ),
        child: Text(
          isGet ? 'プレイ' : '取得',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
