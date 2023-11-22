import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class MemoButtonBar extends StatefulWidget {
  final Function() onCellDelete;
  final Function(bool) onMemoMode; // Callback for memo mode
  final Function() onUndo; // Callback for clearing the memo
  const MemoButtonBar({super.key,
    required this.onCellDelete,
    required this.onMemoMode,
    required this.onUndo,
  });

  @override
  MemoButtonBarState createState() => MemoButtonBarState();
}

class MemoButtonBarState extends State<MemoButtonBar> {
  bool isMemoMode = false; // メモがオンかオフかを追跡するフラグ
  bool isExistHistory = false; // 履歴があるかどうかを追跡するフラグ


  void _handleMemoTap() {
    isMemoMode = !isMemoMode; // メモのオン/オフを切り替える
    widget.onMemoMode(isMemoMode);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children:[
        // Memoボタン
// Memoボタン
InkWell(
  onTap: () => _handleMemoTap(),
  child: Container(
    padding: EdgeInsets.all(8.0), // パディングを追加
    decoration: BoxDecoration(
      color: isMemoMode ? Colors.blueAccent: Colors.grey[200], // 背景色を設定
      borderRadius: BorderRadius.circular(10), // 角を丸くする
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isMemoMode ? Icons.edit : Icons.edit_off, // メモがオンのときはeditアイコン、オフのときはedit_offアイコン
          color: isMemoMode ? Colors.white : null, // メモがオンのときは青色
          size: 40.0, // アイコンのサイズを設定
        ),
        SizedBox(width: 8.0), // アイコンとテキストの間にスペースを追加
        Text(
          isMemoMode ? "memo mode ON" : "memo mode OFF",
          style: TextStyle(
            fontSize: 30.0, // テキストのサイズを設定
            color: isMemoMode ? Colors.white : null, // メモがオンのときは青色
          ),
        ),
      ],
    ),
  ),
),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 元に戻すボタン
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    // 元に戻す機能をここに書く
                    widget.onUndo();
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.undo),
                        onPressed: null, // IconButtonのonPressedはnullに設定
                      ),
                      Text(AppLocalizations.of(context)!.undo),
                    ],
                  ),
                ),
              ],
            ),
            // 消すボタン
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    // 消しゴムの機能をここに書く
                    widget.onCellDelete();
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: null, // IconButtonのonPressedはnullに設定
                      ),
                      Text(AppLocalizations.of(context)!.erase),
                    ],
                  ),
                ),
              ],
            ),

          ],
        ),
      ]
    );
  }
}
