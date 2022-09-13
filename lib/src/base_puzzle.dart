import 'model/cell_model.dart';
import 'model/grid_model.dart';
import 'core/enums.dart';

abstract class BasePuzzle {
  final MatrixDifficulty difficulty;

  BasePuzzle([this.difficulty = MatrixDifficulty.easy]);

  /// Generates the solved and unsolved boards and returns a bool value
  Future<bool> generatePuzzle();

  /// After generation returns the unsolved board
  Grid? unsolvedBoard();

  /// After generation returns the solved board
  Grid? solvedBoard();


  /// Checks whether the cell is valid or not with the solved sudoku
  bool isValid(Cell unSolvedCell);

  /// Returns the time elapsed
  Duration timeElapsed();

  /// Returns a bool whether the stopwatch is running or not
  bool isStopwatchRunning();

  /// To start and stop the stopwatch
  void startStopwatch();
  void stopStopwatch();

  // Callback function that return a cell which has been updated
  void onBoardChange(Function(Cell) handler);

  /// Important to call dispose to stop memory leaks of all the stream subscriptions
  void dispose();
}
