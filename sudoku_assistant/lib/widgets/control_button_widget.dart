import 'package:flutter/material.dart';

class ControlButtonWidget extends StatelessWidget {
  final VoidCallback onClearNotes;
  final VoidCallback onToggleNotes;
  final VoidCallback onChangeNoteColor;
  final VoidCallback onUndo;

  ControlButtonWidget({
    required this.onClearNotes,
    required this.onToggleNotes,
    required this.onChangeNoteColor,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: onClearNotes,
          child: Text("Clear Notes"),
        ),
        ElevatedButton(
          onPressed: onToggleNotes,
          child: Text("Toggle Notes"),
        ),
        ElevatedButton(
          onPressed: onChangeNoteColor,
          child: Text("Change Note Color"),
        ),
        ElevatedButton(
          onPressed: onUndo,
          child: Icon(Icons.undo),
        ),
      ],
    );
  }
}
