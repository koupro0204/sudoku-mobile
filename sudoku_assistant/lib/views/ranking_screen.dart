import 'package:flutter/material.dart';
import 'package:sudoku_assistant/controllers/firebase_puzzle_controller.dart';
import 'package:sudoku_assistant/models/firebase_puzzle.dart';
import 'package:sudoku_assistant/widgets/firebase_pazzule_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku_assistant/services/local_storage_service.dart';
import 'package:sudoku_assistant/models/puzzle.dart';
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
  LocalStorageService localStorageService = LocalStorageService();
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
  Future<PlayingData> _handleGetPlayingDataByPuzzuleId(int id) async {
    // LocalStorageServiceのインスタンスを取得
    
    // getPuzzlesメソッドを呼び出してパズルをデータベースから取得
    var playingData = await localStorageService.getPlayingDataIsPlayingByPuzzleId(id);
    if (playingData.isEmpty) {
      return PlayingData(
        id: null,
        currentGrid: List.generate(9, (_) => List.filled(9, 0)),
      );
    }
    playingData.sort((a, b) => b.id!.compareTo(a.id!));
    return playingData.first;
  }
  void checkLastUpdateTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(prefs.getInt('lastUpdateTime') ?? 0);
    DateTime now = DateTime.now();

    if (now.difference(lastUpdateTime).inHours > 2) {
      // 2時間以上経過していたら更新処理を行う
      deleteAndUpdatePuzzles();
    } else {
      // 2時間以内だったら更新処理を行わない
      updatePuzzles();
    }

    // 現在の時刻を保存
    prefs.setInt('lastUpdateTime', now.millisecondsSinceEpoch);
  }

  void deleteAndUpdatePuzzles() async {
    await firebasePuzzleController.deleteRanking();
    updatePuzzles();
  }

  void updatePuzzles() async {
    int limit = 50;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    // 現在の時刻を保存
    prefs.setInt('lastUpdateTime', now.millisecondsSinceEpoch);

    newestPuzzles = await firebasePuzzleController.loadNewestPuzzles(limit);
    completedPuzzles = await firebasePuzzleController.loadTopCompletedPuzzles(limit);
    numberPuzzles = await firebasePuzzleController.loadNumberOfPlayerPuzzles(limit);
    // ここで更新処理を行う
    setState(() {
      // newestPuzzles = firebasePuzzleController.getNewestPuzzles();
      // completedPuzzles = firebasePuzzleController.getCompletedPuzzles();
    });
  }

  void onSaveButtonPressed(FirebasePuzzle firebasePuzzle) async {
    await firebasePuzzleController.insertFirebasePuzzleForLocalOnRanking(firebasePuzzle);
    updatePuzzles();
    setState(() {});
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
            Tab(text: 'Completed of Player'),
            Tab(text: 'Number of Player'),
          ],
        ),
        // 更新ボタンを追加
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              deleteAndUpdatePuzzles();
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
              const SizedBox(height: 18,),
              Container(
                margin: const EdgeInsets.all(8), // 外側のマージンを追加
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5), // 内側のパディングを追加
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue),
                ),
                child: Text(
                  "Newest",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold, // テキストのフォントの重みを追加
                    color: Colors.blue, // テキストの色を追加
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: newestPuzzles.length,
                  itemBuilder: (context, index) {
                    return FirebasePuzzleEntry(
                      puzzle: newestPuzzles[index],
                      onGetByPuzzuleId: _handleGetPlayingDataByPuzzuleId,
                      onSaveButtonPressed: onSaveButtonPressed,
                      );
                  },
                ),
              ),
            ],
          ),
          Column(
            children: [
              const SizedBox(height: 18,),
              Container(
                margin: const EdgeInsets.all(8), // 外側のマージンを追加
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5), // 内側のパディングを追加
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue),
                ),
                child: Text(
                  "Completed of Player",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold, // テキストのフォントの重みを追加
                    color: Colors.blue, // テキストの色を追加
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: completedPuzzles.length,
                  itemBuilder: (context, index) {
                    return FirebasePuzzleEntry(
                      puzzle: completedPuzzles[index],
                      onGetByPuzzuleId: _handleGetPlayingDataByPuzzuleId,
                      onSaveButtonPressed: onSaveButtonPressed,
                      );
                  },
                ),
              ),
            ],
          ),
          Column(
            children: [
              const SizedBox(height: 18,),
              Container(
                margin: const EdgeInsets.all(8), // 外側のマージンを追加
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5), // 内側のパディングを追加
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue),
                ),
                child: Text(
                  "Number of Player",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold, // テキストのフォントの重みを追加
                    color: Colors.blue, // テキストの色を追加
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: numberPuzzles.length,
                  itemBuilder: (context, index) {
                    return FirebasePuzzleEntry(
                      puzzle: numberPuzzles[index],
                      onGetByPuzzuleId: _handleGetPlayingDataByPuzzuleId,
                      onSaveButtonPressed: onSaveButtonPressed,
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