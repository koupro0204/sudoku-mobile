import 'package:flutter/material.dart';
import 'package:sudoku_assistant/models/puzzle.dart';
import 'package:sudoku_assistant/widgets/preview.dart';
import 'package:sudoku_assistant/views/home_screen.dart';
import 'package:sudoku_assistant/services/local_storage_service.dart';
import 'package:flutter/services.dart';

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
  @override
  void initState(){
    super.initState();
    print(widget.playingData.id);
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
                    builder: (context) => HomeScreen(),
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