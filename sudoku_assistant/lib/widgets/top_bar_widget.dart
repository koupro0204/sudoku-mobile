import 'package:flutter/material.dart';
import 'dart:async';


class TopBarWidget extends StatefulWidget {
  final String puzzleName;

  TopBarWidget({required this.puzzleName});

  @override
  _TopBarWidgetState createState() => _TopBarWidgetState();
}

class _TopBarWidgetState extends State<TopBarWidget> {
  late Duration _elapsedTime;
  late Stopwatch _stopwatch;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _elapsedTime = Duration(seconds: 0);
    _stopwatch = Stopwatch();
    _timer = Timer.periodic(Duration(seconds: 1), _updateTimer);
  }

  void _updateTimer(Timer timer) {
    if (_stopwatch.isRunning) {
      setState(() {
        _elapsedTime = _stopwatch.elapsed;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.puzzleName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text("${_elapsedTime.inMinutes}:${(_elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}", style: TextStyle(fontSize: 18)),
      ],
    );
  }
}
