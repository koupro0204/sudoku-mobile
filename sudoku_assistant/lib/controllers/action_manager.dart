class ActionManager {
  // アクションの履歴を保存するリスト
  final List<PuzzleAction> _history = [];
  final Function(PuzzleAction) undoAction;
  ActionManager({required this.undoAction});
  // アクションを履歴に追加する
  void addAction(PuzzleAction action) {
    _history.add(action);
  }
  // 最後のアクションを取り消す
  void undo() {
    if (_history.isNotEmpty) {
      // 最後のアクションを取り出し、undo処理を行う
      PuzzleAction lastAction = _history.removeLast();
      undoAction(lastAction);
    }
  }
}

// アクションを表すクラス
// 例えばセルに値を設定するアクション
class PuzzleAction {
  final int? x, y;
  final int? oldValue;
  final List<List<int>>? grid;
  final List<int>? memoList;
  final List<List<List<int>>>? memoGrid;

  PuzzleAction({
    this.x,
    this.y,
    this.oldValue,
    this.grid,
    this.memoList,
    this.memoGrid,
  });
}
