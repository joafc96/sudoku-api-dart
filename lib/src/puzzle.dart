import 'dart:async';

import 'package:sudoku_dart/src/base_puzzle.dart';
import 'package:uuid/uuid.dart';

import 'generator.dart';
import 'model/cell_model.dart';
import 'model/grid_model.dart';
import 'core/enums.dart';
import 'utils/puzzle_utils.dart';

class Puzzle extends BasePuzzle {
  late String _id;
  late Generator _generator;
  Grid? _unSolvedBoard;
  Grid? _solvedBoard;
  late Stopwatch _stopwatch;
  int? _timeElapsedInSeconds =
      0; // holds the elapsed time for when getting converted to a map
  late StreamSubscription _boardChangeStreamSub;
  Function(Cell)? _onChangeHandler;

  /// Constructs a new Sudoku puzzle - don't forget to run [generate]
  Puzzle(MatrixDifficulty difficulty) : super(difficulty) {
    _id = const Uuid().v1();
    _stopwatch = Stopwatch();
    _generator = Generator();
    _unSolvedBoard = Grid();
    _solvedBoard = Grid();
  }

  @override
  Future<bool> generatePuzzle() async {
    /* 
     Generates a new puzzle using [difficulty] and returns a bool whether the boards are generated or not. 
     It also starts listening to any changes in the different cells of the grid
    */
    try {
      await _generator.generate(difficulty);

      _unSolvedBoard!.setMatrix = PuzzleUtils.buildUnsolvedBoard(
        _unSolvedBoard,
        _generator.unsolvedBoard,
      )!;
      _solvedBoard!.setMatrix = PuzzleUtils.buildSolvedBoard(
        _solvedBoard,
        _generator.solvedBoard,
      )!;

      _unSolvedBoard!.startListeningToCells();
      _boardChangeStreamSub =
          _unSolvedBoard!.change.listen((cell) => _onBoardChange(cell));

      return true;
    } catch (_) {
      return false;
    }
  }

  /// @cell is the cell which is passed in from the unsolved board after updation
  @override
  bool isValid(Cell unSolvedCell) {
    final Cell solvedCell = _solvedBoard!.cellAt(unSolvedCell.position!);
    if (unSolvedCell.value == solvedCell.value) {
      unSolvedCell.setValidity = true;
      return true;
    }
    return false;
  }

  /// Calls supplied [_onChangeHandler], if you have any assigned through
  /// [onBoardChange]
  void _onBoardChange(Cell cell) {
    if (_onChangeHandler != null) {
      _onChangeHandler!(cell);
    }
  }

  /// Set a [handler] function, which will be called whenever the grid changes.
  /// A change is whenever a cell experiences a change in value.
  @override
  void onBoardChange(Function(Cell) handler) {
    _onChangeHandler = handler;
  }

  /// Terminate listeners, and prepare [Puzzle] for closure
  @override
  void dispose() {
    _boardChangeStreamSub.cancel();
    _unSolvedBoard!.stopListeningCells();
  }

  /// Getters and Setters
  @override
  void startStopwatch() => _stopwatch.start();
  @override
  void stopStopwatch() => _stopwatch.stop();

  /// To check stopwatch is paused or not
  @override
  bool isStopwatchRunning() => _stopwatch.isRunning;

  /// Add the time elapsed in case the game is being reloaded from map/storage
  @override
  Duration timeElapsed() =>
      Duration(seconds: _timeElapsedInSeconds!) + _stopwatch.elapsed;

  @override
  Grid? solvedBoard() => _solvedBoard;

  @override
  Grid? unsolvedBoard() => _unSolvedBoard;
}
