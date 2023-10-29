import 'package:flutter/material.dart';

class NumberButtonWidget extends StatefulWidget {
  final ValueChanged<int> onNumberSelected;
  final int? currentlySelected;

  NumberButtonWidget({required this.onNumberSelected, this.currentlySelected});

  @override
  _NumberButtonWidgetState createState() => _NumberButtonWidgetState();
}

class _NumberButtonWidgetState extends State<NumberButtonWidget> {
  int? _selectedNumber;

  @override
  void initState() {
    super.initState();
    _selectedNumber = widget.currentlySelected;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(9, (index) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: (index + 1) == _selectedNumber ? Colors.blue : Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _selectedNumber = index + 1;
            });
            widget.onNumberSelected(index + 1);
          },
          child: Text((index + 1).toString()),
        );
      }),
    );
  }
}
