import '../model/cell_model.dart';
import '../model/grid_model.dart';
import 'grid_utils.dart';

class PuzzleUtils {
  PuzzleUtils._internal();

  static List<List<Cell>>? buildSolvedBoard(
    Grid? solvedBoard,
    String solvedBoardString,
  ) {
    assert(solvedBoardString.length == 81);
    final solved1D = GridUtils.to1D(solvedBoard!.matrix);
    assert(solved1D.length == solvedBoardString.length);

    for (int cellIdx = 0; cellIdx < solvedBoardString.length; cellIdx++) {
      final solvedCell = solvedBoardString[cellIdx];

      final cellVal = int.tryParse(solvedCell);
      solved1D[cellIdx].setValue = cellVal;
      solved1D[cellIdx].setPristine = true;
      solved1D[cellIdx].setPrefilled = true;
      solved1D[cellIdx].setValidity = true;
    }

    final solved2D = GridUtils.to2D(solved1D);
    return solved2D;
  }

  static List<List<Cell>>? buildUnsolvedBoard(
    Grid? unSolvedBoard,
    String unsolvedBoardString,
  ) {
    assert(unsolvedBoardString.length == 81);
    final unsolved1D = GridUtils.to1D(unSolvedBoard!.matrix);
    assert(unsolved1D.length == unsolvedBoardString.length);

    for (int cellIdx = 0; cellIdx < unsolvedBoardString.length; cellIdx++) {
      final unsolvedCell = unsolvedBoardString[cellIdx];

      final cellVal = int.tryParse(unsolvedCell);

      if (cellVal != 0) {
        unsolved1D[cellIdx].setValue = cellVal;
        unsolved1D[cellIdx].setPristine = true;
        unsolved1D[cellIdx].setPrefilled = true;
        unsolved1D[cellIdx].setValidity = true;
      }
    }

    final unsolved2D = GridUtils.to2D(unsolved1D);
    return unsolved2D;
  }
}
