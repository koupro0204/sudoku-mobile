import 'package:flutter/material.dart';
import 'package:sudoku_assistant/models/puzzle.dart';
import 'package:sudoku_assistant/widgets/preview.dart';
import 'package:sudoku_assistant/views/home_page_screen.dart';
import 'package:sudoku_assistant/services/local_storage_service.dart';
import 'package:flutter/services.dart';
import 'package:sudoku_assistant/controllers/firebase_puzzle_controller.dart';

class CompletedScreen extends StatefulWidget {
  final Puzzle puzzle;
  final PlayingData playingData;
  const CompletedScreen({
    super.key,
    required this.puzzle,
    required this.playingData,
    });

  @override
  CompletedScreenState createState() => CompletedScreenState();
}

class CompletedScreenState extends State<CompletedScreen> {
  Puzzle? updatePazzule;
  final FirebasePuzzleController firebasePuzzleController = FirebasePuzzleController();

  @override
  void initState(){
    super.initState();
  }
  void _handleUpdatePuzzle(Puzzle puzzle) async {
    // LocalStorageServiceのインスタンスを取得
    LocalStorageService localStorageService = LocalStorageService();
    // updatePuzzleメソッドを呼び出してパズルをデータベースに保存
    int _ = await localStorageService.updatePuzzle(puzzle);
    setState(() {
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
// パズルの共有
// ホーム
// 完了時間

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.puzzle.name),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Completed'),
            Text(widget.puzzle.name),
            Text("クリアタイム"),
            Text("${(widget.playingData.elapsedTime ~/ 60).toString().padLeft(2, '0')}:${(widget.playingData.elapsedTime % 60).toString().padLeft(2, '0')}",),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: PreviewGrid(
                grid: widget.puzzle.grid,
                currentState: widget.playingData.currentGrid,
              ),
            ),
            TextButton(
              onPressed: () async {
                // 非同期操作の前にScaffoldMessengerを取得
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                if (widget.puzzle.sharedCode != null) {
                  // 共有コードがすでにある場合は、そのままクリップボードにコピーする
                  Clipboard.setData(ClipboardData(text: widget.puzzle.sharedCode!));
                  // 非同期操作後にScaffoldMessengerを使用
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text("共有コード:${widget.puzzle.sharedCode}をコピーしました"),
                    ),
                  );
                  return;
                }
                updatePazzule = await _handleGetShareCode(widget.puzzle);

                // 共有コードをクリップボードにコピーするロジック
                Clipboard.setData(ClipboardData(text: updatePazzule!.sharedCode!));

                // 非同期操作後にScaffoldMessengerを使用
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text("共有コード:${updatePazzule!.sharedCode}をコピーしました"),
                  ),
                );

                // Navigator.pushReplacement(
                //   context, 
                //   MaterialPageRoute(
                //     builder: (context) => HomeScreen(),
                //   ),
                // );
              },
              child: Text('share'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(),
                  ),);
              },
              child: Text('home'),
            ),
          ],
        ),
      ),
    );
  }

}