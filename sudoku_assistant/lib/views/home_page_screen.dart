import 'package:flutter/material.dart';
import 'package:sudoku_assistant/views/top_screen.dart';
import 'package:sudoku_assistant/views/library_screen.dart';
import 'package:sudoku_assistant/views/share_code_screen.dart';
import 'package:sudoku_assistant/widgets/bannerAds.dart';
import 'package:sudoku_assistant/views/ranking_screen.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0; // 現在選択されているタブのインデックス

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        // 広告を再読み込みしないように、IndexedStackで画面を切り替える
        index: _selectedIndex,
        children: <Widget>[
          // ここにタブごとの画面ウィジェットを追加
          TopScreen(),  // インデックス0
          RankingPage(), // インデックス1
          PuzzleLibraryScreen(), // インデックス2
          EnterSharedCodeScreen(), // インデックス3
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                activeIcon: Icon(Icons.home),
                label: 'Top',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.leaderboard),
                activeIcon: Icon(Icons.leaderboard),
                label: 'Ranking',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_books),
                activeIcon: Icon(Icons.library_books),
                label: 'Library',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.share),
                activeIcon: Icon(Icons.share),
                label: 'Share',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.amber[800],
            unselectedItemColor: Colors.grey,
              onTap: (int index) {
                setState(() {
                  _selectedIndex = index; // タップされたタブのインデックスを更新
                });
              },
          ),
          BannerAdWidget(adUnitId: "ca-app-pub-3940256099942544/6300978111"),
        ],
      )
    );
  }
}
