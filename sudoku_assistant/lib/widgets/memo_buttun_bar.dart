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
        // Memoボタン
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => _handleMemoTap(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      isMemoMode ? Icons.edit : Icons.edit_off, // メモがオンのときはeditアイコン、オフのときはedit_offアイコン
                      color: isMemoMode ? Colors.blue : null, // メモがオンのときは青色
                    ),
                    onPressed: null, // IconButtonのonPressedはnullに設定
                    iconSize: 40.0, // アイコンのサイズを大きく設定
                  ),
                  Text(AppLocalizations.of(context)!.memo),
                ],
              ),
            ),
          ],
        ),
      ],
    );

  }
}
