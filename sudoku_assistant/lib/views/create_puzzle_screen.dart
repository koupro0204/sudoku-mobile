import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sudoku_assistant/controllers/puzzle_controller.dart';
import 'package:sudoku_assistant/services/local_storage_service.dart';
import 'package:sudoku_assistant/models/puzzle.dart';
import 'package:sudoku_assistant/widgets/number_button_bar.dart';
import 'package:sudoku_assistant/widgets/sudoku_grid.dart';
import 'package:sudoku_assistant/widgets/memo_buttun_bar.dart';
import 'package:sudoku_assistant/widgets/save_button.dart';
import 'package:sudoku_assistant/widgets/preview.dart';
import 'package:sudoku_assistant/views/home_screen.dart';

class CreatePuzzleScreen extends StatefulWidget {
  const CreatePuzzleScreen({super.key});

  @override
  _CreatePuzzleScreenState createState() => _CreatePuzzleScreenState();
}

class _CreatePuzzleScreenState extends State<CreatePuzzleScreen> {
  final PuzzleController _puzzleController = PuzzleController();
  // final ActionManager _actionManager = ActionManager();
  @override
  void initState() {
    super.initState();
    _puzzleController.selectedRow=0;
    _puzzleController.selectedCol=0;
  }
  void _handleCellTap(int x, int y) {
    _puzzleController.handleCellTap(x, y);
    setState(() {}); // Refresh the UI with the updated grid state
  }
  void _savePuzzle(String name) async {
    // LocalStorageServiceのインスタンスを取得
    LocalStorageService localStorageService = LocalStorageService();

    // パズルデータを作成
    Puzzle puzzle = Puzzle(
      name: name,
      grid: _puzzleController.grid,
      creationDate: DateTime.now(),
      status: "not",
      currentState: _puzzleController.grid,
      source: "created",
    );

    // insertPuzzleメソッドを呼び出してパズルをデータベースに保存
    int _ = await localStorageService.insertPuzzle(puzzle);
  }
  void _handleNumberTap(int number) {
    // Set the selected number in the controller
    // If a cell was previously selected, apply the number to that cell
    if (_puzzleController.selectedRow != null && _puzzleController.selectedCol != null) {
      _puzzleController.selectedNumber = number;
      _puzzleController.handleNumberInput(_puzzleController.selectedRow!, _puzzleController.selectedCol!);
    }
      _puzzleController.selectedNumber = null;
    setState(() {});
  }
  void _handleNumberLongPress(int number) {
    _puzzleController.selectedNumber = number;
    _puzzleController.handleFixedMode(number);
    setState(() {});
  }

  void _handleNumberLock(bool isLocked) {
    // Lock or unlock the selected number
    _puzzleController.setNumberLockState(isLocked);
    setState(() {});
  }
  void _handleReset() {
    _puzzleController.handleReset();
    setState(() {});
  }
  void _handlePreview() {
    // 保存の機能をここに書く
    // _puzzleController.handlePreview();
    _showSaveDialog(context);
  } 

  void _handleCellDelete() {
    _puzzleController.handleCellDelete();
    setState(() {});
  }
  void _handleMemoMode(bool isMemoMode) {
    _puzzleController.setMemoMode(isMemoMode);
    setState(() {});
  }

  void _handleUndo() {
    _puzzleController.actionManager.undo();
    setState(() {});
  }
  // AlertDialogがポップアップとして表示されます。
  void _showSaveDialog(BuildContext context) {
    // 名前を入力するためのテキストコントローラ
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.preview),
          content: SingleChildScrollView(
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min, // 内容に合わせてサイズを最小限にする
                children: <Widget>[
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.name, // 入力欄のラベル
                    ),
                  ),
                  PreviewGrid(grid: _puzzleController.grid), // プレビューグリッドを表示
                ],
              ),
            ),
          ),
          actions: <Widget>[
            // キャンセルボタン
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
            ),
            // 保存ボタン
            TextButton(
              child: Text(AppLocalizations.of(context)!.save),
              onPressed: () {
                // 保存処理を実行するコードをここに書く
                // 例えば、名前を含むパズルを保存するなど
                String name = nameController.text; // 入力された名前を取得
                // 名前とパズルデータを使って保存処理を実行
                if (name.isEmpty) {
                  name = 'No Name';
                }
                _savePuzzle(name);
                // home_screenに戻る。ライブラリ画面ができたらそこに飛ばしてもいいし、問題画面でもいい
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double gridWidth = screenWidth * 0.98; // 98% of the screen width
    double gridMarginTop = MediaQuery.of(context).size.height * 0.01; // 1% of the screen height
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.generate_sudoku),
      ),
      body: Column(
        children: [
          SizedBox(height: gridMarginTop), // Add a margin at the top of the grid (optional
          Expanded(
            child: Center( // Center is added to center the Container
              child: SizedBox(
                width: gridWidth, // Set the width of the Container
                child: SudokuGrid(
                  onCellTap: _handleCellTap,
                  grid: _puzzleController.grid,
                  invalidCells: _puzzleController.invalidCells,
                  highlightedCells: _puzzleController.highlightedCells,
                  selectedcell: _puzzleController.selectedCell,
                  memoGrid: _puzzleController.memoGrid,
                ),
              ),
            ),
          ),
          SizedBox(height: gridMarginTop), // Add a margin at the top of the grid (optional
          MemoButtonBar(
            onCellDelete: _handleCellDelete,
            onMemoMode: _handleMemoMode,
            onUndo: _handleUndo,
          ),
          SizedBox(height: gridMarginTop), // Add a margin at the top of the grid (optional
          NumberButtonBar(
            onNumberTap: _handleNumberTap,
            onNumberLongPress: _handleNumberLongPress,
            onNumberLock: _handleNumberLock,
          ),
          SizedBox(height: gridMarginTop), // Add a margin at the top of the grid (optional
          SaveButtonBar(
            onReset: _handleReset,
            onPreview: _handlePreview,
          ),
          SizedBox(height: gridMarginTop), // Add a margin at the top of the grid (optional
          // Add Preview and Save button implementations here
        ],
      ),
    );
  }
}
