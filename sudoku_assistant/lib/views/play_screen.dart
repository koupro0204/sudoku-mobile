import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sudoku_assistant/controllers/puzzle_controller.dart';
import 'package:sudoku_assistant/services/local_storage_service.dart';
import 'package:sudoku_assistant/models/puzzle.dart';
import 'package:sudoku_assistant/widgets/number_button_bar.dart';
import 'package:sudoku_assistant/widgets/sudoku_grid.dart';
import 'package:sudoku_assistant/widgets/memo_buttun_bar.dart';
import 'package:sudoku_assistant/widgets/top_bar.dart';
import 'package:sudoku_assistant/views/completed_screen.dart';
import 'package:sudoku_assistant/views/home_screen.dart';
class PlayPuzzleScreen extends StatefulWidget {
  final Puzzle puzzle;
  final PlayingData playingData;
  const PlayPuzzleScreen({
    super.key,
    required this.puzzle,
    required this.playingData,
    });

  @override
  PlayPuzzleScreenState createState() => PlayPuzzleScreenState();
}

class PlayPuzzleScreenState extends State<PlayPuzzleScreen> {
  final PuzzleController _puzzleController = PuzzleController();
  late int elapsedTime;
  late PlayingData playingData;
  @override
  void initState() {
    super.initState();
    initializePlayingData();
  }

  Future<void> initializePlayingData() async {
    if (widget.playingData.id != null && widget.playingData.status != PlayStatusNumber.completed) {
      // プレイ中のパズルの場合、プレイ中のパズルのデータを読み込む
      playingData = widget.playingData;
    } else {
      // プレイ中のパズルでない場合、新しいplayDataを作成する
      PlayingData newPlayingData = PlayingData(
        id: null,
        puzzleId: widget.puzzle.id,
        currentGrid: List<List<int>>.from(widget.puzzle.grid.map((list) => List<int>.from(list))),
        memoGrid: List.generate(9, (_) => List.generate(9, (_) => <int>[])),
        elapsedTime: 0,
        status: PlayStatusNumber.playing,
      );

      // データを保存し、新しいIDを取得
      int newId = await LocalStorageService().insertPlayingData(newPlayingData);

      // 新しいIDでplayingDataを更新
      playingData = PlayingData(
        id: newId,
        puzzleId: widget.puzzle.id,
        currentGrid: newPlayingData.currentGrid,
        memoGrid: newPlayingData.memoGrid,
        elapsedTime: newPlayingData.elapsedTime,
        status: newPlayingData.status,
      );
    }

    // その他の初期化処理
    _puzzleController.selectedRow = 0;
    _puzzleController.selectedCol = 0;
    _puzzleController.initialGrid = widget.puzzle.grid;
    _puzzleController.grid = playingData.currentGrid;
    _puzzleController.memoGrid = playingData.memoGrid!;
    _puzzleController.inspect.updateGrid(_puzzleController.grid, _puzzleController.invalidCells);
    _puzzleController.validator.updateGrid(_puzzleController.grid, _puzzleController.memoGrid);
    _puzzleController.validator.validate();

    _puzzleController.highlightManager.highlightAllRelatedCells(0, 0, widget.puzzle.grid);
    elapsedTime = widget.playingData.elapsedTime;

    // 状態を更新
    if (mounted) setState(() {});
  }


  Future<void> _savePuzzle() async {
    // LocalStorageServiceのインスタンスを取得
    LocalStorageService localStorageService = LocalStorageService();
    if (_puzzleController.isCompleted) {
      // パズルが完了した場合、パズルのステータスをcompletedにして保存
      // パズルデータを作成
      Puzzle puzzle = Puzzle(
        id: widget.puzzle.id,
        name: widget.puzzle.name,
        grid: widget.puzzle.grid,
        creationDate: widget.puzzle.creationDate,
        status: _puzzleController.isCompleted ? StatusNumber.completed : StatusNumber.none,
        source: widget.puzzle.source,
      );
      int _ = await localStorageService.updatePuzzle(puzzle);
      // playingDataを完了にして保存
      PlayingData draftPlayingData = PlayingData(
        id: playingData.id,
        puzzleId: playingData.puzzleId,
        currentGrid: _puzzleController.grid,
        memoGrid: _puzzleController.memoGrid,
        elapsedTime: elapsedTime,
        status: PlayStatusNumber.completed,
      );
      await localStorageService.updatePlayingData(draftPlayingData);
      playingData = draftPlayingData;
    } else {
      PlayingData draftPlayingData = PlayingData(
        id: playingData.id,
        puzzleId: playingData.puzzleId,
        currentGrid: _puzzleController.grid,
        memoGrid: _puzzleController.memoGrid,
        elapsedTime: elapsedTime,
        status: PlayStatusNumber.playing,
      );
      // updatePuzzleメソッドを呼び出してパズルをデータベースに保存
      await localStorageService.updatePlayingData(draftPlayingData);
      playingData = draftPlayingData;
    }
  }
  
  void _handleCellTap(int x, int y) async {
    _puzzleController.handleCellTap(x, y);
    setState(() {}); // Refresh the UI with the updated grid state
    if (_puzzleController.isCompleted) {
      await _savePuzzle();
      // 非同期処理後にBuildContextがまだ有効かを確認
      if (!mounted) return;
      // パズルが完了したら画面遷移
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CompletedScreen(
          puzzle: widget.puzzle,
          playingData: playingData,
          )
        ) 
      );
    }
  }
  void _handleNumberTap(int number) async{
    // Set the selected number in the controller
    // If a cell was previously selected, apply the number to that cell
    if (_puzzleController.selectedRow != null && _puzzleController.selectedCol != null) {
      _puzzleController.selectedNumber = number;
      _puzzleController.handleNumberInput(_puzzleController.selectedRow!, _puzzleController.selectedCol!);
    }
      // _puzzleController.selectedNumber = null;
    //setState内で完了を検知
    setState(()  {
    });
      if (_puzzleController.isCompleted) {
        await _savePuzzle();
        // 非同期処理後にBuildContextがまだ有効かを確認
        if (!mounted) return;
        // パズルが完了したら画面遷移
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CompletedScreen(
            puzzle: widget.puzzle,
            playingData: playingData,
            )
          ) 
        );
      }
    
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
  void _handleElapseTime(int newElapsedTime) {
    setState(() {
      elapsedTime = newElapsedTime;
    });
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double gridWidth = screenWidth * 0.98; // 98% of the screen width
    double gridMarginTop = MediaQuery.of(context).size.height * 0.01; // 1% of the screen height
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.generate_sudoku),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // パズルを保存
            _savePuzzle();
            // home_screen.dartに遷移
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: gridMarginTop),
          TopBarPlayScreenWidget(
            elapsedSeconds: widget.playingData.elapsedTime,
            onTimeChanged: _handleElapseTime,
            name: widget.puzzle.name,
          ),

          SizedBox(height: MediaQuery.of(context).size.height * 0.005),
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
                  initialGrid: _puzzleController.initialGrid
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
          // Add Preview and Save button implementations here
        ],
      ),
    );
  }
}
