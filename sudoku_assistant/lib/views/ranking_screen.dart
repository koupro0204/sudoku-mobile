import 'package:flutter/material.dart';

class RankingPage extends StatefulWidget {
  @override
  _RankingPagetate createState() => _RankingPagetate();
}

class _RankingPagetate extends State<RankingPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 3つのタブ
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ranking List'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Completed Player'),
            Tab(text: 'Number of Player'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ここにタブごとの画面ウィジェットを追加
          // CompletedPlayerRankingPage(),  // インデックス0
          // NumberButtonBar(), // インデックス0
          // NumberButtonBar(), // インデックス0
          Center(child: Text('Completed Player Ranking Page')),
          Center(child: Text('Number of Player Ranking Page')),
          // NumberOfPlayerRankingPage(), // インデックス1
        ],
      ),
    );
  }
}