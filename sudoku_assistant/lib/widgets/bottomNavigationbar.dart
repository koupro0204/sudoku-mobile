import 'package:flutter/material.dart';
import 'package:sudoku_assistant/views/home_screen.dart';
import 'package:sudoku_assistant/views/library_screen.dart';
import 'package:sudoku_assistant/views/share_code_screen.dart';
// import 'package:sudoku_assistant/views/ranking_screen.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  CustomBottomNavigationBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
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
      currentIndex: currentIndex,
      selectedItemColor: Colors.amber[800],
      unselectedItemColor: Colors.grey,
      onTap: (int index) {
        switch (index) {
          case 0:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (Route<dynamic> route) => false,
            );
            break;
          case 1:
            // RankingScreenへのナビゲーションロジック
            break;
          case 2:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => PuzzleLibraryScreen()),
              (Route<dynamic> route) => false,
            );
            break;
          case 3:
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => EnterSharedCodeScreen()),
              (Route<dynamic> route) => false,
            );
            break;
        }
      },
    );
  }
}
