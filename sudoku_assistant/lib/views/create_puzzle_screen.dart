import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sudoku_assistant/controllers/create_puzzle_controller.dart';
import 'package:sudoku_assistant/services/local_storage_service.dart';
import 'package:sudoku_assistant/models/puzzle.dart';
import 'package:sudoku_assistant/widgets/number_button_bar.dart';
import 'package:sudoku_assistant/widgets/sudoku_grid.dart';
import 'package:sudoku_assistant/widgets/memo_buttun_bar.dart';
import 'package:sudoku_assistant/widgets/save_button.dart';
import 'package:sudoku_assistant/widgets/preview.dart';
import 'package:sudoku_assistant/views/home_screen.dart';
import 'package:sudoku_assistant/views/play_screen.dart';
class CreatePuzzleScreen extends StatefulWidget {
  final Puzzle? puzzle;
  const CreatePuzzleScreen({
    super.key,
    this.puzzle,
    });

  @override
  CreatePuzzleScreenState createState() => CreatePuzzleScreenState();
}

class CreatePuzzleScreenState extends State<CreatePuzzleScreen> {
  final CreatePuzzleController _puzzleController = CreatePuzzleController();
  // final ActionManager _actionManager = ActionManager();
  @override
  void initState() {
    super.initState();
    _puzzleController.selectedRow=0;
    _puzzleController.selectedCol=0;
    if (widget.puzzle != null) {
      _puzzleController.grid = widget.puzzle!.grid;
    }
    _puzzleController.validator.updateGrid(_puzzleController.grid, _puzzleController.memoGrid);
    _puzzleController.validator.validate();
    _puzzleController.highlightManager.highlightAllRelatedCells(0, 0, _puzzleController.grid);
    setState(() {});
  } 
  void _handleCellTap(int x, int y) {
    _puzzleController.handleCellTap(x, y);
    setState(() {}); // Refresh the UI with the updated grid state
  }
  Future<Puzzle> savePuzzle(String name) async {
    // LocalStorageServiceのインスタンスを取得
    LocalStorageService localStorageService = LocalStorageService();
    if (widget.puzzle != null) {
      if (name=='No Name') {
        if (widget.puzzle!.name=='No Name'){
          name = 'No Name';
        }else{
          name = widget.puzzle!.name;
        }
      }
      // パズルデータを作成
      Puzzle puzzle = Puzzle(
        id: widget.puzzle!.id,
        name: name,
        grid: _puzzleController.grid,
        creationDate: DateTime.now(),
        status: StatusNumber.none,
        source: SourceNumber.created,
      );
      // updatePuzzleメソッドを呼び出してパズルをデータベースに保存
      int _ = await localStorageService.updatePuzzle(puzzle);
      return puzzle;
    }else{
      // パズルデータを作成
      Puzzle puzzle = Puzzle(
        name: name,
        grid: _puzzleController.grid,
        creationDate: DateTime.now(),
        status: StatusNumber.none,
        source: SourceNumber.created,
      );

      // insertPuzzleメソッドを呼び出してパズルをデータベースに保存
      int insertedId = await localStorageService.insertPuzzle(puzzle);
      puzzle = puzzle.copyWith(id: insertedId);
      return puzzle;

    }
  }
  void _handleNumberTap(int number) {
    // Set the selected number in the controller
    // If a cell was previously selected, apply the number to that cell
    if (_puzzleController.selectedRow != null && _puzzleController.selectedCol != null) {
      _puzzleController.selectedNumber = number;
      _puzzleController.handleNumberInput(_puzzleController.selectedRow!, _puzzleController.selectedCol!);
    }
      // _puzzleController.selectedNumber = null;
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
    Puzzle createdPuzzle;
    // 名前を入力するためのテキストコントローラ
    // 初期値を設定
    String initialText = widget.puzzle?.name ?? '';
    if (initialText == 'No Name') {
      initialText = '';
    }
    TextEditingController nameController = TextEditingController(text: initialText);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.preview),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, // 内容に合わせてサイズを最小限にする
              children: <Widget>[
                TextField(
                  controller: nameController,
                  maxLength: 15, // 入力数を15文字に制限
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.name, // 入力欄のラベル
                  ),
                ),
                    Flexible(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: PreviewGrid(
                          grid: _puzzleController.grid,
                          currentState: _puzzleController.grid,
                        ),
                      ),
                    )
              ],
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
              onPressed: () async {
                // 保存処理を実行するコードをここに書く
                // 例えば、名前を含むパズルを保存するなど
                String name = nameController.text; // 入力された名前を取得
                // 名前とパズルデータを使って保存処理を実行
                if (name.isEmpty) {
                  name = 'No Name';
                }
                await savePuzzle(name);
                if (!mounted) return; // ここでウィジェットがまだマウントされているか確認
                // home_screenに戻る。
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
            // 保存and play ボタン
            TextButton(
              child: Text("Save And Play"),
              // child: Text(AppLocalizations.of(context)!.save),
              onPressed: () async {
                // 保存処理を実行するコードをここに書く
                // 例えば、名前を含むパズルを保存するなど
                String name = nameController.text; // 入力された名前を取得
                // 名前とパズルデータを使って保存処理を実行
                if (name.isEmpty) {
                  name = 'No Name';
                }
                createdPuzzle = await savePuzzle(name);
                if (!mounted) return; // ここでウィジェットがまだマウントされているか確認
                // play 画面に遷移する。
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => 
                    PlayPuzzleScreen(
                      puzzle: createdPuzzle,
                      playingData: PlayingData(
                        id: null,
                        currentGrid: createdPuzzle.grid,
                        
                        )
                      )
                    ),
                  (Route<dynamic> route) => false,
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
    bool isInvalid = _puzzleController.invalidCells.any((row) => row.any((cell) => cell == true));
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.generate_sudoku),
        // leadingのボタンの挙動を設定する必要あり
        
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
                  selectedNumber: _puzzleController.selectedNumber,
                  grid: _puzzleController.grid,
                  invalidCells: _puzzleController.invalidCells,
                  highlightedCells: _puzzleController.highlightedCells,
                  selectedcell: _puzzleController.selectedCell,
                  memoGrid: _puzzleController.memoGrid,
                  initialGrid: _puzzleController.grid,
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
            grid: _puzzleController.grid,
            isNumberLocked: _puzzleController.isNumberLocked,
          ),
          SizedBox(height: gridMarginTop), // Add a margin at the top of the grid (optional
          SaveButtonBar(
            onReset: _handleReset,
            onPreview: _handlePreview,
            isInvalid: isInvalid,
          ),
          SizedBox(height: gridMarginTop), // Add a margin at the top of the grid (optional
          // Add Preview and Save button implementations here
        ],
      ),
    );
  }
}
