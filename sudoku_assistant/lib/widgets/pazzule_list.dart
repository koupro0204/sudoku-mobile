import 'package:flutter/material.dart';
import 'package:sudoku_assistant/models/puzzle.dart';
import 'package:flutter/services.dart'; 
import 'package:sudoku_assistant/widgets/preview.dart';
import 'package:intl/intl.dart';

class PuzzleEntry extends StatelessWidget {
  final Puzzle puzzle;
  final Function(Puzzle) onShare; // Callback for sharing the puzzle
  const PuzzleEntry({super.key,
    required this.onShare,
    required this.puzzle
  });
  static const badgeTextStyle = TextStyle(color: Colors.white, fontSize: 12);
  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (puzzle.status == StatusNumber.completed || puzzle.status == StatusNumber.shared) {
          // パズルのステータスが completed または shared の場合、ダイアログを表示
          return AlertDialog(
            title: Text("パズルをシェア"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("このパズルをシェアしますか？"),
                PreviewGrid(
                  grid: puzzle.grid,
                  currentState: puzzle.currentState,
                  ),
                if (puzzle.sharedCode != null) ...[
                  SizedBox(height: 16), // 余白を追加
                  Text("共有コード: ${puzzle.sharedCode}"),
                  SizedBox(height: 16), // 余白を追加
                  ElevatedButton(
                    onPressed: () {
                      // 共有コードをクリップボードにコピーするロジック
                      Clipboard.setData(ClipboardData(text: puzzle.sharedCode!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("共有コード:${puzzle.sharedCode}をコピーしました"),
                        ),
                      );
                    },
                    child: Text("コピー"),
                  ),
                ],
              ],
            ),
            actions: <Widget>[
              MaterialButton(
                child: Text("キャンセル"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              puzzle.sharedCode != null
                  ? Container()
                  : MaterialButton(
                      child: Text("シェア"),
                      onPressed: () async {
                        final updatePuzzle = onShare(puzzle);
                        updatePuzzle.then((value) {
                          Clipboard.setData(ClipboardData(text: value.sharedCode!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("共有コード: ${value.sharedCode}をコピーしました"),
                            ),
                          );
                          Navigator.of(context).pop();
                        });
                      },
                    ),
            ],
          );
        } else {
          // パズルのステータスが completed または shared でない場合、別のダイアログを表示
          return AlertDialog(
            title: Text("パズルをシェア"),
            content: Text("このパズルはまだ完成していません。"),
            actions: <Widget>[
              MaterialButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
      },
    );
  }

  // パズルのステータスに応じて適切なバッジを生成するメソッド
  Widget _buildStatusBadge() {
    String statusText;
    Color badgeColor;

    if (puzzle.status == StatusNumber.shared) {
      statusText = '共有中';
      badgeColor = Colors.deepPurpleAccent.shade400; // 共有中/クリア済みのバッジの色
    } else if (puzzle.status == StatusNumber.completed) {
      statusText = 'クリア済み';
      badgeColor = Colors.green; // クリア済みのバッジの色
    } else {
      statusText = '未完了';
      badgeColor = Colors.grey; // 未完了のバッジの色
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
  // パズルの作成元に応じて適切なバッジを生成するメソッド
  Widget _buildSourceBadge() {
    String statusText;
    Color badgeColor;

    if (puzzle.source == SourceNumber.share) {
      statusText = '共有';
      badgeColor = Colors.blue; // 共有中/クリア済みのバッジの色
    } else {
      statusText = '自作';
      badgeColor = Colors.orange; // クリア済みのバッジの色
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

  // AlertDialogがポップアップとして表示されます。
  void _showPreviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(puzzle.name),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, // 内容に合わせてサイズを最小限にする
              children: <Widget>[
                PreviewGrid(
                  grid: puzzle.grid,
                  currentState: puzzle.currentState,
                  ), // プレビューグリッドを表示
              ],
            ),
          ),
          actions: <Widget>[
            // キャンセルボタン
            TextButton(
              child: Text("close"),
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
            ),
            // 保存ボタン
            TextButton(
              child: Text("play"),
              onPressed: () {
                // 問題画面に遷移する
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(builder: (context) => const HomeScreen()),
                // );
              },
            ),
          ],
        );
      },
    );
  }


@override
Widget build(BuildContext context) {
  return ListTile(
    onTap: () {
      // パズルの詳細画面に遷移するコードをここに追加
      _showPreviewDialog(context);
    },
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSourceBadge(),
                _buildStatusBadge(),
              ],
            ),
            SizedBox(width: 3), // バッジと名前の間にスペースを追加
            Text(puzzle.name),
          ],
        ),
        SizedBox(height: 3), // 一段目と二段目の間にスペースを追加
        Text(
          'Created on ${DateFormat('yyyy-MM-dd HH:mm').format(puzzle.creationDate)}',
          style: TextStyle(
            fontSize: 12, // サブタイトルのフォントサイズを調整
          ),
        ),
      ],
    ),
    trailing: IconButton(
      icon: Icon(Icons.share),
      onPressed: () {
        _showShareDialog(context); // パズルを共有するダイアログを表示
      },
    ),
  );
}
}
