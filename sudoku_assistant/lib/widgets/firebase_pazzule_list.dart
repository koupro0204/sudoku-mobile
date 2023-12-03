import 'package:flutter/material.dart';
import 'package:sudoku_assistant/models/firebase_puzzle.dart';
import 'package:sudoku_assistant/models/puzzle.dart';
import 'package:intl/intl.dart';

class FirebasePuzzleEntry extends StatelessWidget {
  final FirebasePuzzle puzzle;
  // final Function(int) onGetByPuzzuleId;
  // final Function(Puzzle) onShare; // Callback for sharing the puzzle
  const FirebasePuzzleEntry({super.key,
    // required this.onShare,
    required this.puzzle,
    // required this.onGetByPuzzuleId,
  });

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
      // _showPreviewDialog(context);
    },
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        SizedBox(height: 3), // 一段目と二段目の間にスペースを追加
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // _buildSourceBadge(),
                _buildStatusBadge(),
              ],
            ),
            SizedBox(width: 3), // バッジと名前の間にスペースを追加
            Text(puzzle.name),
          ],
        ),
        Text(
          puzzle.completedPlayer.toString() + '/' + puzzle.numberOfPlayer.toString() + '人がクリア済み',
          style: TextStyle(
            fontSize: 14, // サブタイトルのフォントサイズを調整
          ),
        ),
        Text(
          'Created on ${DateFormat('yyyy-MM-dd HH:mm').format(puzzle.creationDate)}',
          style: TextStyle(
            fontSize: 12, // サブタイトルのフォントサイズを調整
          ),
        ),

      ],
    ),
    trailing: ElevatedButton(
      onPressed: () {
        // _showShareDialog(context); // パズルを共有するダイアログを表示
      },
      style: ButtonStyle(
        backgroundColor: isGet
            ? MaterialStateProperty.all<Color>(Colors.blue) // 選択されたボタンの背景色
            : MaterialStateProperty.all<Color>(Colors.greenAccent.shade700), // 選択されていないボタンの背景色
      ),
      child: Text(
        isGet ?'プレイ':"取得",
        style: TextStyle(
          color: Colors.white, // テキストの色
        ),
      ),
    ),
  );
}
}
