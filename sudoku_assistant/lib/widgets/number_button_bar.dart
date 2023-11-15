import 'package:flutter/material.dart';

class NumberButtonBar extends StatefulWidget {
  final Function(int) onNumberTap;
  final Function(int) onNumberLongPress;
  final Function(bool) onNumberLock; // Callback for locking the number
  final List<List<int>> grid;
  final bool isNumberLocked;

  const NumberButtonBar({super.key, 
    required this.onNumberTap,
    required this.onNumberLongPress,
    required this.onNumberLock,
    required this.grid,
    required this.isNumberLocked,
  });

  @override
  NumberButtonBarState createState() => NumberButtonBarState();
}

class NumberButtonBarState extends State<NumberButtonBar> {
  int? _selectedNumber;

  void _handleNumberTap(int number) {
    if (widget.isNumberLocked) {
      // If a number is already locked, unlock it first
      _selectedNumber = null;
      widget.onNumberLock(false);
    } else{
      widget.onNumberTap(number);
    }
    setState(() {});
  }

  void _handleNumberLongPress(int number) {
    // // Long press will lock the number
    if (widget.isNumberLocked && _selectedNumber == number) {
      // If the number is already locked, unlock it
      widget.onNumberLock(false);
      _selectedNumber = null;
    } else {
      // Select the number and lock it
      _selectedNumber = number;
      widget.onNumberLock(true);
      widget.onNumberLongPress(number);
    }

    setState(() {});
  }
  Map<int, int> _countNumbersInGrid(List<List<int>> grid) {
    Map<int, int> numberCount = {};
    for (var row in grid) {
      for (var number in row) {
        if (number != 0) { // 0 は無視する
          numberCount[number] = (numberCount[number] ?? 0) + 1;
        }
      }
    }
    return numberCount;
  }

  @override
  Widget build(BuildContext context) {
    // grid内の各数字の出現回数をカウント
    Map<int, int> numberCount = _countNumbersInGrid(widget.grid);

    return Padding(
      padding: EdgeInsets.only(left: 10.0, right: 10.0,top: 10.0, bottom: 20.0),
      child: Row(
        children: 
        List.generate(9, (index) {
          int number = index + 1;
          // この数字が9回出現した場合は非表示にする
          bool shouldHide = numberCount[number] == 9;
          // if (shouldHide) {
          //   // If a number is locked, hide all other numbers
          //   _isNumberLocked = false;
          // }
          return Expanded(
            child: shouldHide 
              ? Container() // 数字が9回出現した場合は何も表示しない
              : TextButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedNumber == number && widget.isNumberLocked
                        ? null
                        : null
                        // : Colors.white.withOpacity(0.95), // 選択された数字をハイライト
                  ),
                  onPressed: () => _handleNumberTap(number),
                  onLongPress: () => _handleNumberLongPress(number),
                  child: Text(
                    '$number',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color:  widget.isNumberLocked
                          ? _selectedNumber == number
                          ? Colors.blue.shade800 :Colors.blue.shade800.withOpacity(0.2)
                          : Colors.blue.shade800,
                    ),
                  ),
                ),
          );
        }),
      )
    );
  }
}
