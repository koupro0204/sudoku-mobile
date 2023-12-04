import 'package:flutter/material.dart';
import 'package:sudoku_assistant/models/puzzle.dart';
import 'package:sudoku_assistant/widgets/pazzule_list.dart';
import 'package:sudoku_assistant/services/local_storage_service.dart';
import 'package:sudoku_assistant/controllers/firebase_puzzle_controller.dart';
import 'package:sudoku_assistant/controllers/trigger_tab_contoroller.dart';

enum SourceFilter { all, created, shared }
enum StatusFilter { all, none, completed, shared }
class PuzzleLibraryScreen extends StatefulWidget {
    final TriggerNotifierContoller triggerNotifierContoller;
    const PuzzleLibraryScreen({
      Key? key,
      required this.triggerNotifierContoller,
      });
  @override
  _PuzzleLibraryScreenState createState() => _PuzzleLibraryScreenState();
}

class _PuzzleLibraryScreenState extends State<PuzzleLibraryScreen> {
  bool _isLoaded = false;
  SourceFilter _selectedSourceFilter = SourceFilter.all;
  StatusFilter _selectedStatusFilter = StatusFilter.all;
  List<Puzzle> puzzles = []; // This should be populated with your puzzle data
  final FirebasePuzzleController firebasePuzzleController = FirebasePuzzleController();
  @override
  void initState() {
    super.initState();
    _isLoaded = false;
    _getFPuzzles();
  }

  Future<List<Puzzle>> _getFPuzzles() async {
    // LocalStorageServiceのインスタンスを取得
    LocalStorageService localStorageService = LocalStorageService();

    // getPuzzlesメソッドを非同期で呼び出し、結果を待つ
    List<Puzzle> puzzles = await localStorageService.getPuzzles();
    _isLoaded = true;
    // puzzlesをcreationDateに基づいて新しい順に並べ替える
    puzzles.sort((a, b) => b.id!.compareTo(a.id!));

    // 状態を更新するためにsetStateを呼び出す必要がある場合は、ここで行う
    setState(() {
      this.puzzles = puzzles;
    });

    return puzzles;
  }

  List<Puzzle> _getFilteredPuzzles() {
    // puzzlesが空の場合、初期化する
    if (puzzles.isEmpty && !_isLoaded) {
      _getFPuzzles();
    }

    return puzzles.where((puzzle) {
      // ソースフィルタの条件
      bool sourceFilterPassed = _selectedSourceFilter == SourceFilter.all ||
                                (_selectedSourceFilter == SourceFilter.created && puzzle.source == SourceNumber.created) ||
                                (_selectedSourceFilter == SourceFilter.shared && puzzle.source == SourceNumber.share);

      // ステータスフィルタの条件
      bool statusFilterPassed = _selectedStatusFilter == StatusFilter.all ||
                                (_selectedStatusFilter == StatusFilter.none && puzzle.status == StatusNumber.none) ||
                                (_selectedStatusFilter == StatusFilter.completed && puzzle.status == StatusNumber.completed) ||
                                (_selectedStatusFilter == StatusFilter.shared && puzzle.status == StatusNumber.shared);

      // 両方のフィルタを満たすかどうか
      return sourceFilterPassed && statusFilterPassed;
    }).toList();
  }

  void _handleUpdatePuzzle(Puzzle puzzle) async {
    // LocalStorageServiceのインスタンスを取得
    LocalStorageService localStorageService = LocalStorageService();
    // updatePuzzleメソッドを呼び出してパズルをデータベースに保存
    int _ = await localStorageService.updatePuzzle(puzzle);
    // パズルが更新されたので、ウィジェットをリフレッシュ
    setState(() {
      // パズルリストを再取得
      _getFPuzzles();
    });
  }

  Future<Puzzle> _handleGetShareCode(Puzzle puzzle) async {
    try {
      Puzzle? updatedPuzzle = await firebasePuzzleController.addPuzzle(puzzle);
      if (updatedPuzzle == null) {
        return puzzle;
      }
      
      _handleUpdatePuzzle(updatedPuzzle);
      return updatedPuzzle;
    } catch (e) {
      // エラーハンドリング
      print('Firebaseからデータを取得できませんでした: $e');
      return puzzle; // エラーが発生した場合は元のパズルを返すか、エラー処理を行います
    }
  }

  Future<PlayingData> _handleGetPlayingDataByPuzzuleId(int id) async {
    // LocalStorageServiceのインスタンスを取得
    LocalStorageService localStorageService = LocalStorageService();
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

  @override
  Widget build(BuildContext context) {
    List<Puzzle> filteredPuzzles = _getFilteredPuzzles();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Puzzle Library'),
      ),

      body: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: widget.triggerNotifierContoller.isUpdateTriggerNotifier,
            builder: (context, value, child) {
              if (value == true) {
                print("gbggggggg");
                _getFPuzzles(); // 条件を満たすときに関数を実行
                widget.triggerNotifierContoller.isUpdateTriggerNotifier.value = false;
              }
              return Container(); // UIの変更は必要ない場合はContainerを返す
            },
          ),
          _buildFilterButtons(),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPuzzles.length,
              itemBuilder: (context, index) {
                return PuzzleEntry(
                  puzzle: filteredPuzzles[index],
                  onGetByPuzzuleId: _handleGetPlayingDataByPuzzuleId,
                  onShare: _handleGetShareCode,
                  );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: SourceFilter.values.map((filter) {
            final isSelected = filter == _selectedSourceFilter;
            return ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedSourceFilter = filter;
                });
              },
              style: ButtonStyle(
                backgroundColor: isSelected
                    ? MaterialStateProperty.all<Color>(Colors.blue) // 選択されたボタンの背景色
                    : MaterialStateProperty.all<Color>(Colors.white), // 選択されていないボタンの背景色
              ),
              child: Text(
                filter.toString().split('.').last,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black, // テキストの色
                ),
              ),
            );
          }).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: StatusFilter.values.map((filter) {
            final isSelected = filter == _selectedStatusFilter;
            return ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedStatusFilter = filter;
                });
              },
              style: ButtonStyle(
                backgroundColor: isSelected
                    ? MaterialStateProperty.all<Color>(Colors.blue) // 選択されたボタンの背景色
                    : MaterialStateProperty.all<Color>(Colors.white), // 選択されていないボタンの背景色
              ),
              child: Text(
                filter.toString().split('.').last,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black, // テキストの色
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }



}


