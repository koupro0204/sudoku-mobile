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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Memoボタン
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isMemoMode ? Icons.edit : Icons.edit_off, // メモがオンのときはeditアイコン、オフのときはedit_offアイコン
                color: isMemoMode ? Colors.blue : null, // メモがオンのときは青色
              ),
              onPressed: () => _handleMemoTap(),
            ),
            Text(AppLocalizations.of(context)!.memo)
          ],
        ),
        // 消すボタン
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // 消しゴムの機能をここに書く
                widget.onCellDelete();
              },
            ),
            Text(AppLocalizations.of(context)!.erase)
          ],
        ),
        // 元に戻すボタン
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: () {
                // 元に戻す機能をここに書く
                widget.onUndo();
              },
            ),
            Text(AppLocalizations.of(context)!.undo)
          ],
        ),
      ],
    );
  }
}
