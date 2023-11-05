import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SaveButtonBar extends StatefulWidget{
  final Function() onReset;
  const SaveButtonBar({super.key, 
    required this.onReset,
  });
  @override
  _SaveButtonBarState createState() => _SaveButtonBarState();
}

class _SaveButtonBarState extends State<SaveButtonBar> {
  void _handleReset() {
    widget.onReset();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // リセットボタン
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                // リセットの機能をここに書く
                _handleReset();
              },
            ),
            Text(AppLocalizations.of(context)!.reset)
          ],
        ),
        // 保存ボタン
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                // 保存の機能をここに書く
              },
            ),
            Text(AppLocalizations.of(context)!.save)
          ],
        ),
      ],
    );
  }
}