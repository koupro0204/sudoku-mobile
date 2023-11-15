import 'dart:async';
import 'package:flutter/material.dart';

class TopBarPlayScreenWidget extends StatefulWidget {
  final int elapsedSeconds;
  final Function(int) onTimeChanged;
  final String name;

  const TopBarPlayScreenWidget({
    super.key,
    required this.elapsedSeconds,
    required this.onTimeChanged,
    required this.name,
  });

  @override
  _TopBarPlayScreenWidgetState createState() => _TopBarPlayScreenWidgetState();
}

class _TopBarPlayScreenWidgetState extends State<TopBarPlayScreenWidget> with WidgetsBindingObserver {
  Timer? _timer;
  late int _elapsedSeconds;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _elapsedSeconds = widget.elapsedSeconds;
    _startOrResumeTimer();
  }

  void _startOrResumeTimer() {
    _timer?.cancel(); // 既存のタイマーがあればキャンセル
    _timer = Timer.periodic(
      Duration(seconds: 1),
      (Timer timer) {
        setState(() {
          _elapsedSeconds++;
        });
        widget.onTimeChanged(_elapsedSeconds);
      },
    );
  }

  void _pauseTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // アプリがバックグラウンドに移動したとき
      _pauseTimer();
    } else if (state == AppLifecycleState.resumed) {
      // アプリが再びアクティブになったとき
      _startOrResumeTimer();
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20.0), // 左側の余白
          child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "name",
                  style: TextStyle(
                    fontSize: 13,
                    // fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  widget.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 30.0),
          child: Column(
            children: [
              Text(
                'Time',
                style: TextStyle(
                  fontSize: 13,
                  // fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(
                '${(_elapsedSeconds ~/ 60).toString().padLeft(2, '0')}:${(_elapsedSeconds % 60).toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 14,
                  // fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
