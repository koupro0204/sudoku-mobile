import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class MemoButtonBar extends StatefulWidget {
  final Function() onCellDelete;
  const MemoButtonBar({super.key,
    required this.onCellDelete,
  });

  @override
  _MemoButtonBarState createState() => _MemoButtonBarState();
}

class _MemoButtonBarState extends State<MemoButtonBar> {
  bool isMemoOn = false; // メモがオンかオフかを追跡するフラグ

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
                isMemoOn ? Icons.edit : Icons.edit_off, // メモがオンのときはeditアイコン、オフのときはedit_offアイコン
                color: isMemoOn ? Colors.blue : null, // メモがオンのときは青色
              ),
              onPressed: () {
                setState(() {
                  isMemoOn = !isMemoOn; // メモのオン/オフを切り替える
                });
              },
            ),
            Text(AppLocalizations.of(context)!.memo)
          ],
        ),
        // 消すボタン
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.delete),
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
              icon: Icon(Icons.undo),
              onPressed: () {
                // 元に戻す機能をここに書く
              },
            ),
            Text(AppLocalizations.of(context)!.undo)
          ],
        ),
      ],
    );
  }
}
