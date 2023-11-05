import 'package:flutter/material.dart';

class NumberButtonBar extends StatefulWidget {
  final Function(int) onNumberTap;
  final Function(int) onNumberLongPress;
  final Function(bool) onNumberLock; // Callback for locking the number

  const NumberButtonBar({super.key, 
    required this.onNumberTap,
    required this.onNumberLongPress,
    required this.onNumberLock,
  });

  @override
  _NumberButtonBarState createState() => _NumberButtonBarState();
}

class _NumberButtonBarState extends State<NumberButtonBar> {
  int? _selectedNumber;
  bool _isNumberLocked = false; // To track if a number is locked

  void _handleNumberTap(int number) {
    if (_isNumberLocked) {
      // If a number is already locked, unlock it first
      _isNumberLocked = false;
      _selectedNumber = null;
      widget.onNumberLock(_isNumberLocked);
    } else{
      widget.onNumberTap(number);
    }
    setState(() {});
  }

  void _handleNumberLongPress(int number) {
    // // Long press will lock the number
    if (_isNumberLocked && _selectedNumber == number) {
      // If the number is already locked, unlock it
      _isNumberLocked = false;
      _selectedNumber = null;
    } else {
      // Select the number and lock it
      _selectedNumber = number;
      _isNumberLocked = true;
      widget.onNumberLongPress(number);
    }

    widget.onNumberLock(_isNumberLocked);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(9, (index) {
        return Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedNumber == index + 1 && _isNumberLocked
                  ? Colors.blueAccent
                  : Colors.lightBlueAccent[100], // Highlight the selected number if locked
            ),
            onPressed: () => _handleNumberTap(index + 1),
            onLongPress: () => _handleNumberLongPress(index + 1),
            child:  Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: _selectedNumber == index + 1 && _isNumberLocked
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
        );
      }),
    );
  }
}
