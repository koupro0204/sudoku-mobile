import 'package:flutter/material.dart';
import 'package:sudoku_assistant/models/puzzle.dart';
import 'package:sudoku_assistant/widgets/pazzule_list.dart';
import 'package:sudoku_assistant/services/local_storage_service.dart';

enum PuzzleFilter { all, created, shared }

class PuzzleLibraryScreen extends StatefulWidget {
  @override
  _PuzzleLibraryScreenState createState() => _PuzzleLibraryScreenState();
}

class _PuzzleLibraryScreenState extends State<PuzzleLibraryScreen> {
  PuzzleFilter _selectedFilter = PuzzleFilter.all;
  List<Puzzle> puzzles = []; // This should be populated with your puzzle data

  @override
  void initState() {
    super.initState();
    _getFPuzzles();
  }

  Future<List<Puzzle>> _getFPuzzles() async {
    // LocalStorageServiceのインスタンスを取得
    LocalStorageService localStorageService = LocalStorageService();

    // getPuzzlesメソッドを非同期で呼び出し、結果を待つ
    List<Puzzle> puzzles = await localStorageService.getPuzzles();

    // puzzlesをcreationDateに基づいて新しい順に並べ替える
    puzzles.sort((a, b) => b.creationDate.compareTo(a.creationDate));

    // 状態を更新するためにsetStateを呼び出す必要がある場合は、ここで行う
    setState(() {
      this.puzzles = puzzles;
    });

    return puzzles;
  }

  
  List<Puzzle> _getFilteredPuzzles() {
    // Implement your filter logic here based on _selectedFilter
    // For now, it just returns all puzzles
    if (puzzles.isEmpty) {
      _getFPuzzles();
    }
    if (_selectedFilter == PuzzleFilter.all) {
      return puzzles;
    } else if (_selectedFilter == PuzzleFilter.created) {
      return puzzles.where((puzzle) => puzzle.source == SourceNumber.created).toList();
    } else if (_selectedFilter == PuzzleFilter.shared) {
      return puzzles.where((puzzle) => puzzle.source == SourceNumber.share).toList();
    }
    return puzzles;
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
      // Firebaseからデータを取得する非同期処理
      // 例: Firestoreからデータを取得する場合
      // var snapshot = await FirebaseFirestore.instance.collection('puzzles').doc(puzzle.id).get();
      // var data = snapshot.data();
      
      // データ取得後の処理
      // var sharedCode = data['sharedCode'];
      var sharedCode = "eightLen"; // データから取得した共有コードに置き換える
      
      Puzzle updatedPuzzle = Puzzle(
        id: puzzle.id,
        grid: puzzle.grid,
        name: puzzle.name,
        status: puzzle.status,
        creationDate: puzzle.creationDate,
        sharedCode: sharedCode, // データから取得した共有コードに置き換える
        source: puzzle.source,
      );
      
      _handleUpdatePuzzle(updatedPuzzle);
      return updatedPuzzle;
    } catch (e) {
      // エラーハンドリング
      print('Firebaseからデータを取得できませんでした: $e');
      return puzzle; // エラーが発生した場合は元のパズルを返すか、エラー処理を行います
    }
  }

  Future<PlayingData> _handleGetByPuzzuleId(int id) async {
    // LocalStorageServiceのインスタンスを取得
    LocalStorageService localStorageService = LocalStorageService();
    // getPuzzlesメソッドを呼び出してパズルをデータベースから取得
    var playingData = await localStorageService.getPlayingDataByPuzzleId(id);
    if (playingData.isEmpty) {
      return PlayingData(
        id: null,
        currentGrid: List.generate(9, (_) => List.filled(9, 0)),
      );
    }
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
          _buildFilterButtons(),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPuzzles.length,
              itemBuilder: (context, index) {
                return PuzzleEntry(
                  puzzle: filteredPuzzles[index],
                  onGetByPuzzuleId: _handleGetByPuzzuleId,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: PuzzleFilter.values.map((filter) {
        final isSelected = filter == _selectedFilter;
        return ElevatedButton(
          onPressed: () {
            setState(() {
              _selectedFilter = filter;
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
    );
  }



}


