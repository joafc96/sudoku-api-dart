import 'dart:convert';
import 'dart:math';

import '../model/candidates_model.dart';
import '../core/constants.dart';
import '../core/enums.dart';
import '../core/exceptions.dart';

class GeneratorUtils {
  const GeneratorUtils._internal();

  static List shuffleSeq(List seq) {
    /* Return a shuffled version of `seq`
    Temp seq is created to not shuffle the passed seq
     */

    final List tempSeq = [];

    for (int seqIdx = 0; seqIdx < seq.length; seqIdx++) {
      tempSeq.add(seq[seqIdx]);
    }

    tempSeq.shuffle();
    return tempSeq;
  }

  static int randRange(int max, [int min = 0]) {
    /* Get a random integer in the range of `min` to `max` (non inclusive).
        If `min` not defined, default to 0. If `max` not defined, throw an
        error.
        */

    final random = Random();
    return min + random.nextInt(max - min);
  }

  static bool isIn(v, seq) {
    /* Return if a value `v` is in sequence `seq`.
     */
    return seq.indexOf(v) != -1;
  }

  static stripDups(List seq) {
    /* Strip duplicate values from `seq`
     */
    var seqSet = [];
    var dupMap = {};
    for (int seqIdx = 0; seqIdx < seq.length; seqIdx++) {
      final e = seq[seqIdx];
      if (dupMap[e] == null) {
        seqSet.add(e);
        dupMap[e] = true;
      }
    }
    return seqSet;
  }

  static List<String> cross(String a, String b) {
    /* Cross product of all elements in `a` and `b`, e.g.,
      sudoku._cross("abc", "123") ->
      ["a1", "a2", "a3", "b1", "b2", "b3", "c1", "c2", "c3"]
      */
    List<String> result = [];
    for (int aIdx = 0; aIdx < a.length; aIdx++) {
      for (int bIdx = 0; bIdx < b.length; bIdx++) {
        result.add(a[aIdx] + b[bIdx]);
      }
    }
    return result;
  }

  static List<List<String>> getAllUnits() {
    /* Return a list of all units (rows, cols, segments) */

    final List<List<String>> tmpAllUnits = [];

    // rows
    for (int row = 0; row < rowSize; row++) {
      tmpAllUnits.add(cross(rows[row], cols));
    }

    //columns
    for (int column = 0; column < columnSize; column++) {
      tmpAllUnits.add(cross(rows, cols[column]));
    }

    // segments
    for (int row = 0; row < rowSquares.length; row++) {
      for (int column = 0; column < colSquares.length; column++) {
        tmpAllUnits.add(cross(rowSquares[row], colSquares[column]));
      }
    }

    return tmpAllUnits;
  }

  static Map<String, List<List<String>>> getCellUnitsMap(
      List<String> cells, List<List<String>> allUnits) {
    /* Return a map of `cells` and their associated units
    Each cell has 3 units they are (row, col, segments)
     */

    Map<String, List<List<String>>> cellUnitsMap = {};

    // For every cell...
    for (int cellIdx = 0; cellIdx < cells.length; cellIdx++) {
      final String curCell = cells[cellIdx];

      // Maintain a list of the current cell's units
      List<List<String>> curCellUnits = [];

      // Look through the units, and see if the current cell is in it,
      // and if so, add it to the list of of the cell's units.
      for (int unitIdx = 0; unitIdx < allUnits.length; unitIdx++) {
        List<String> curUnit = allUnits[unitIdx];

        if (curUnit.contains(curCell)) {
          curCellUnits.add(curUnit);
        }
      }

      // Save the current cell and its units to the map
      cellUnitsMap[curCell] = curCellUnits;
    }

    return cellUnitsMap;
  }

  static getCellPeersMap(
      List<String> cells, Map<String, List<List<String>>> cellUnitsMap) {
    /* Return a map of `cells` and their associated peers, i.e., a set of
        other cells in the cells's unit.
        Each cell has exactly 20 peers.
        */

    Map<String, Set<String>> tmpCellPeersMap = {};

    // For every cell...
    for (int cellIdx = 0; cellIdx < cells.length; cellIdx++) {
      final String curCell = cells[cellIdx];
      final List<List<String>> curCellUnits = cellUnitsMap[curCell]!;

      // Maintain list of the current cell's peers
      Set<String> curCellPeers = {};

      // Look through the current cell's units map...
      for (int cellUnitIdx = 0;
          cellUnitIdx < curCellUnits.length;
          cellUnitIdx++) {
        List<String> curUnit = curCellUnits[cellUnitIdx];

        for (int unitIdx = 0; unitIdx < curUnit.length; unitIdx++) {
          String curUnitCell = curUnit[unitIdx];

          if (!curCellPeers.contains(curUnitCell) && curUnitCell != curCell) {
            curCellPeers.add(curUnitCell);
          }
        }
      }

      tmpCellPeersMap[curCell] = curCellPeers;
    }

    return tmpCellPeersMap;
  }

  static Map<String, String> getGridValuesMap(
      String board, List<String> cells) {
    /* Return a map of cell's -> values
     */
    Map<String, String> gridValsMap = {};

    // Make sure `board` is a string of length 81
    if (board.length != cells.length) {
      throw "Board/cells length mismatch.";
    } else {
      for (int cellIdx = 0; cellIdx < cells.length; cellIdx++) {
        gridValsMap[cells[cellIdx]] = board[cellIdx];
      }
    }
    return gridValsMap;
  }

  static String buildUnsolvedBoardWithDifficulty(
    Candidates candidates,
    List<String> cells,
    MatrixDifficulty difficulty,
  ) {
    /* Return a string of an unsolved board
    candidates are the values returned after generation of a board
    cells are the list of cells
    difficulty is the difficulty for the board should be built on
    */
    String board = "";
    List generatedIndexes = [];
    for (int cellIdx = 0; cellIdx < cells.length; cellIdx++) {
      final cell = cells[cellIdx];
      if (candidates.candidatesMap[cell]?.length == 1) {
        board += candidates.candidatesMap[cell]!;
        generatedIndexes.add(cellIdx);
      } else {
        board += blankChar;
      }
    }

    // If we have more than `difficulty` givens, remove some random
    // givens until we're down to exactly `difficulty`
    int totalGenerated = generatedIndexes.length;
    if (totalGenerated > difficulty.value) {
      generatedIndexes = shuffleSeq(generatedIndexes);
      for (var i = 0; i < totalGenerated - difficulty.value; i++) {
        final int target = generatedIndexes[i];
        board =
            "${board.substring(0, target)}$blankChar${board.substring(target + 1)}";
      }
    }

    return board;
  }

// Implement a better deep copy than this ridiculous solution (Strings are Immutable (reason I have used json encode here) and Collections are not)
  static Candidates? deepClone(
    Candidates? candidates,
  ) {
    return Candidates.fromJson(jsonDecode(jsonEncode(candidates)));
  }

  static void validateBoard(String board) {
    /* Return if the given `board` is valid or not. If it's valid, return
      true. If it's not, return a string of the reason why it's not.
      */

    // Check for empty board
    if (board.isEmpty) {
      throw InvalidSudokuConfigurationException();
    }

    // Invalid board length
    if (board.length != boardSize) {
      throw InvalidSudokuConfigurationException();
    }

    // Check for invalid characters
    for (int bIdx = 0; bIdx < board.length; bIdx++) {
      if (!isIn(board[bIdx], ".0") && !isIn(board[bIdx], digits)) {
        throw InvalidSudokuConfigurationException();
      }
    }

    // Otherwise, we're good. Return.
    return;
  }
}
