import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SaveButtonBar extends StatefulWidget{
  final Function() onReset;
  final Function() onPreview;
  final bool isInvalid;
  const SaveButtonBar({super.key, 
    required this.onReset,
    required this.onPreview,
    required this.isInvalid,
  });
  @override
  SaveButtonBarState createState() => SaveButtonBarState();
}

class SaveButtonBarState extends State<SaveButtonBar> {
  void _handleReset() {
    widget.onReset();
    setState(() {});
  }

  void _handlePreview(){
    // 保存の機能をここに書く
    widget.onPreview();
    setState(() {});

  }

  void _showInvalidPreviewDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('無効な操作'),
            content: Text('エラーが存在するため、保存できません。'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // ダイアログを閉じる
                },
              ),
            ],
          );
        },
    );
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
              icon: const Icon(Icons.refresh),
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

              icon: const Icon(Icons.save),
              onPressed: () {
                if(widget.isInvalid){
                  _showInvalidPreviewDialog(context);
                }else{
                  _handlePreview();
                }
              },
            ),
            Text(AppLocalizations.of(context)!.save)
          ],
        ),
      ],
    );
  }
}