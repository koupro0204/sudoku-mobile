import 'package:flutter/material.dart';
import 'package:sudoku_assistant/controllers/firebase_puzzle_controller.dart';
import 'package:sudoku_assistant/models/firebase_puzzle.dart';
import 'package:sudoku_assistant/widgets/firebase_pazzule_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RankingPage extends StatefulWidget {
  @override
  _RankingPagetate createState() => _RankingPagetate();
}

class _RankingPagetate extends State<RankingPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<FirebasePuzzle> newestPuzzles = [];
  List<FirebasePuzzle> completedPuzzles = [];
  List<FirebasePuzzle> numberPuzzles = [];
  FirebasePuzzleController firebasePuzzleController = FirebasePuzzleController();
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3つのタブ
    checkLastUpdateTime();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void checkLastUpdateTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(prefs.getInt('lastUpdateTime') ?? 0);
    print("最終更新時刻: $lastUpdateTime");
    DateTime now = DateTime.now();

    if (now.difference(lastUpdateTime).inHours > 2) {
      // 2時間以上経過していたら更新処理を行う
      updatePuzzles();
    }

    // 現在の時刻を保存
    prefs.setInt('lastUpdateTime', now.millisecondsSinceEpoch);
  }

  void updatePuzzles() async {
    int limit = 50;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    // 現在の時刻を保存
    prefs.setInt('lastUpdateTime', now.millisecondsSinceEpoch);

    newestPuzzles = await firebasePuzzleController.loadNewestPuzzles(limit);
    completedPuzzles = await firebasePuzzleController.loadTopCompletedPuzzles(limit);
    numberPuzzles = await firebasePuzzleController.loadNumnerOfPlayerPuzzles(limit);
    // ここで更新処理を行う
    setState(() {
      // newestPuzzles = firebasePuzzleController.getNewestPuzzles();
      // completedPuzzles = firebasePuzzleController.getCompletedPuzzles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ranking List'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Newest'),
            Tab(text: 'Completed Player'),
            Tab(text: 'Number of Player'),
          ],
        ),
        // 更新ボタンを追加
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              updatePuzzles();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ここにタブごとの画面ウィジェットを追加
          Column(
            children: [
              Text('Newest'),
              Expanded(
                child: ListView.builder(
                  itemCount: newestPuzzles.length,
                  itemBuilder: (context, index) {
                    return FirebasePuzzleEntry(
                      puzzle: newestPuzzles[index],
                      );
                  },
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text('Completed Player'),
              Expanded(
                child: ListView.builder(
                  itemCount: completedPuzzles.length,
                  itemBuilder: (context, index) {
                    return FirebasePuzzleEntry(
                      puzzle: completedPuzzles[index],
                      );
                  },
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text('Number of Player'),
              Expanded(
                child: ListView.builder(
                  itemCount: numberPuzzles.length,
                  itemBuilder: (context, index) {
                    return FirebasePuzzleEntry(
                      puzzle: numberPuzzles[index],
                      );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}