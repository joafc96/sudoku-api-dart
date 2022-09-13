import 'package:sudoku_dart/src/model/candidates_model.dart';

import 'core/constants.dart';
import 'core/enums.dart';
import 'utils/generator_utils.dart';

class Generator {
  List<String>? _cells;
  List<List<String>>? _allUnits;
  Map<String, List<List<String>>>? _cellUnitsMap;
  Map<String, Set<String>>? _cellPeersMap;

  String _solvedBoard = "";
  String get solvedBoard => _solvedBoard;

  String _unsolvedBoard = "";
  String get unsolvedBoard => _unsolvedBoard;

  Generator() {
    _cells = GeneratorUtils.cross(rows, cols);
    _allUnits = GeneratorUtils.getAllUnits();
    _cellUnitsMap = GeneratorUtils.getCellUnitsMap(_cells!, _allUnits!);
    _cellPeersMap = GeneratorUtils.getCellPeersMap(_cells!, _cellUnitsMap!);
  }

  Future<void> generate(MatrixDifficulty difficulty, [bool unique = true]) async {
    // Get a set of cells and all possible candidates for each cell
    String blankBoard = "";
    for (int bIdx = 0; bIdx < boardSize; bIdx++) {
      blankBoard += blankChar;
    }

    final Candidates? candidates = _getCandidatesMap(blankBoard);

    // For each item in a shuffled list of cells
    final shuffledCells = GeneratorUtils.shuffleSeq(_cells!);

    for (int shCellIdx = 0; shCellIdx < _cells!.length; shCellIdx++) {
      final shuffledCell = shuffledCells[shCellIdx];

      // If an assignment of a random chioce causes a contradictoin, give up and try again
      final int randCandidateIdx = GeneratorUtils.randRange(
          candidates!.candidatesMap[shuffledCell]!.length);
      final String randCandidate =
          candidates.candidatesMap[shuffledCell]![randCandidateIdx];

      if (_assign(candidates, shuffledCell, randCandidate) == null) {
        break;
      }

      // Make a list of all single candidates
      List<String?> singleCandidates = [];
      for (int cellIdx = 0; cellIdx < _cells!.length; cellIdx++) {
        final String cell = _cells![cellIdx];

        if (candidates.candidatesMap[cell]?.length == 1) {
          singleCandidates.add(candidates.candidatesMap[cell]);
        }
      }

      // If we have at least difficulty, and the unique candidate count is
      // at least 8, return the puzzle!
      if (singleCandidates.length >= difficulty.value &&
          GeneratorUtils.stripDups(singleCandidates).length >= 8) {
        _unsolvedBoard = GeneratorUtils.buildUnsolvedBoardWithDifficulty(
            candidates, _cells!, difficulty);

        // Solve the generated board (Expensive Task)
        final Candidates? solvedCandidates = _solve(_unsolvedBoard);

        if (solvedCandidates != null) {
          for (int cdIdx = 0;
              cdIdx < solvedCandidates.candidatesMap.length;
              cdIdx++) {
            // update the solved board after board generation
            _solvedBoard += solvedCandidates.candidatesMap[_cells![cdIdx]]!;
          }
          return;
        }
      }
    }

    return generate(difficulty);
  }

  Candidates? _assign(Candidates? candidates, String cell, String assignVal) {
    /* Eliminate all values, *except* for `assignVal`, from `candidates` at 
        `cell` (candidates[cell]), and propagate. Return true
        when finished. If a contradiciton is found, return false.
        WARNING: This will modify the contents of `candidates` directly (Dart functions are pass by reference).
        */

    // Grab a list of candidates without 'assignVal'
    final String otherValsToBeRemovedFromCell =
        candidates!.candidatesMap[cell]!.replaceAll(assignVal, "");

    /* Loop through all other values and eliminate them from the candidates
     at the current cell, and propogate. If at any point we get a
     contradiction, return false else return true.
     */
    for (int otherValIdx = 0;
        otherValIdx < otherValsToBeRemovedFromCell.length;
        otherValIdx++) {
      final String otherValToBeRemoved =
          otherValsToBeRemovedFromCell[otherValIdx];
      final candidatesNext = _eliminate(candidates, cell, otherValToBeRemoved);

      if (candidatesNext == null) {
        return null;
      }
    }

    return candidates;
  }

  Candidates? _eliminate(
      Candidates? candidates, String cell, String eliminateVal) {
    /* Eliminate `val` from `candidates` at `cell`, (candidates[cell]),
        and propagate when values or places <= 2. Return updated candidates,
        unless a contradiction is detected, in which case, return false.
        (1) If a cell has only one possible value, then eliminate that value from the cell’s peers.\
        (2) If a unit has only one possible place for a value, then put the value there.
        WARNING: This will modify the contents of `candidates` directly (Dart functions are pass by reference).
        */

    // If `val` has already been eliminated from candidates[cell], return with true. (## Already eliminated)
    if (!GeneratorUtils.isIn(eliminateVal, candidates!.candidatesMap[cell])) {
      return candidates;
    }

    // Remove `eliminateVal` from candidates[cell] (one by one) (will eventually result in the assignment of assignVal to the shuffled cell)
    candidates.candidatesMap[cell] =
        candidates.candidatesMap[cell]!.replaceAll(eliminateVal, "");

    final int numberOfCandidates = candidates.candidatesMap[cell]!.length;

    // If the cell has no candidates, we have a contradiction then return false.  (## Contradiction: removed last value)
    if (numberOfCandidates == 0) {
      return null;
    }

    // (1) If the cell has only one candidate left, eliminate that value from its peers
    if (numberOfCandidates == 1) {
      final String targetVal = candidates.candidatesMap[cell]!;

      for (int peerIdx = 0; peerIdx < _cellPeersMap![cell]!.length; peerIdx++) {
        final String peer = _cellPeersMap![cell]!.elementAt(peerIdx);
        final candidatesNew = _eliminate(candidates, peer, targetVal);

        if (candidatesNew == null) {
          return null;
        }
      }
    }

    // (2) If a unit is reduced to only one place for a value, then assign the value to the corresponding cell
    for (int unitsIdx = 0;
        unitsIdx < _cellUnitsMap![cell]!.length;
        unitsIdx++) {
      // Get the current unit of the current cell which can be a row, column or a segment
      final List<String> units = _cellUnitsMap![cell]![unitsIdx];

      List<String> valPlaces = [];
      for (int cellIdx = 0; cellIdx < units.length; cellIdx++) {
        final String unitCell = units[cellIdx];
        if (GeneratorUtils.isIn(
            eliminateVal, candidates.candidatesMap[unitCell])) {
          valPlaces.add(unitCell);
        }
      }

      // If there's no place for this value, we have a contradition return false (## Contradiction: no place for this value)
      if (valPlaces.isEmpty) {
        return null;

        // Otherwise the value can only be in one place. Assign it there.
      } else if (valPlaces.length == 1) {
        final candidatesNew = _assign(candidates, valPlaces[0], eliminateVal);

        if (candidatesNew == null) {
          return null;
        }
      }
    }

    return candidates;
  }

  Candidates? _solve(String board, [reverse = false]) {
    /* Solve a sudoku puzzle given a sudoku `board`, i.e., an 81-character 
      string of sudoku.DIGITS, 1-9, and spaces identified by '.', representing the
      cell's. There must be a minimum of 17 givens. If the given board has no
      solutions, return false.
      
      Optionally set `reverse` to solve "backwards", i.e., rotate through the
      possibilities in reverse. Useful for checking if there is more than one
      solution.
      */

    GeneratorUtils.validateBoard(board);

    // new candidates are required for solve method which can include single possible values or digits
    final Candidates? candidates = _getCandidatesMap(board);

    final Candidates? result = _search(candidates!, reverse);

    if (result != null) {
      return result;
    }
    return null;
  }

  Candidates? _search(Candidates? candidates, [reverse = false]) {
    /* Given a map of cell's -> candidates, using depth-first search, 
      recursively try all possible values until a solution is found, or false
      if no solution exists. 
      */

    // Return if error in previous iteration
    if (candidates == null) {
      return null;
    }

    // If only one candidate for every cell, we've a solved puzzle!
    // Return the candidates.
    int maxNumberOfCandidates = 0;
    for (int cellIdx = 0; cellIdx < _cells!.length; cellIdx++) {
      final String cell = _cells![cellIdx];
      final int numberOfCandidatesOfCell =
          candidates.candidatesMap[cell]!.length;
      if (numberOfCandidatesOfCell > maxNumberOfCandidates) {
        maxNumberOfCandidates = numberOfCandidatesOfCell;
      }
    }

    // If every cell has exactly one value, the puzzle is solved.
    if (maxNumberOfCandidates == 1) {
      return candidates;
    }

    // Choose the blank cell with the fewest possibilities > 1
    //(Select a cell with minimum number of potential values, and call assign to eliminate a potential value from the peers)
    int minNumberOfCandidates = 10;
    String? cellMinCandidate;
    for (int cellIdx = 0; cellIdx < _cells!.length; cellIdx++) {
      final String cell = _cells![cellIdx];

      final int numberOfCandidates = candidates.candidatesMap[cell]!.length;

      if (numberOfCandidates < minNumberOfCandidates &&
          numberOfCandidates > 1) {
        minNumberOfCandidates = numberOfCandidates;
        cellMinCandidate = cell;
      }
    }

    /* Recursively search through each of the candidates of the cell starting with the one with fewest candidates.
     Rotate through the candidates forwards
     Call the search function recursively by passing the values after the above elimination
    Note: values are copied and passed down to the assign call to avoid book-keeping complexity.
    */
    final String? minCandidates = candidates.candidatesMap[cellMinCandidate];

    if (!reverse) {
      for (int cdIdx = 0; cdIdx < minCandidates!.length; cdIdx++) {
        final String minVal = minCandidates[cdIdx];
        final candidatesCopy = GeneratorUtils.deepClone(candidates);

        final candidatesNext =
            _search(_assign(candidatesCopy, cellMinCandidate!, minVal));

        if (candidatesNext != null) {
          return candidatesNext;
        }
      }

      // Rotate through the candidates backwards
    } else {
      for (int cdIdx = minCandidates!.length - 1; cdIdx >= 0; cdIdx--) {
        final String minVal = minCandidates[cdIdx];
        final candidatesCopy = GeneratorUtils.deepClone(candidates);

        final candidatesNext = _search(
          _assign(candidatesCopy, cellMinCandidate!, minVal),
          reverse,
        );

        if (candidatesNext != null) {
          return candidatesNext;
        }
      }
    }

    // If we get through all combinations of the cell with the fewest
    // candidates without finding an answer, there isn't one. Return false.
    return null;
  }

  Candidates? _getCandidatesMap(board) {
    /* Get all possible candidates for each cell as a map in the form
        {cell: sudoku.DIGITS} using recursive constraint propagation. Return `false` 
        if a contradiction is encountered
        If the board contains non blank cells assign its value to the candidates map with DIGITS 
        */

    GeneratorUtils.validateBoard(board);

    Candidates tmpCandidates = Candidates();
    tmpCandidates.candidatesMap = {};

    final Map<String, String> gridValuesMap =
        GeneratorUtils.getGridValuesMap(board, _cells!);

    // Start by assigning every digit as a candidate to every cell
    for (int cellIdx = 0; cellIdx < _cells!.length; cellIdx++) {
      tmpCandidates.candidatesMap[_cells![cellIdx]] = digits;
    }

    // For each non-blank cell, assign its value in the candidate map and propogate.
    for (int cellIdx = 0; cellIdx < _cells!.length; cellIdx++) {
      final String val = gridValuesMap[_cells![cellIdx]]!;
      final String cell = _cells![cellIdx];

      if (GeneratorUtils.isIn(val, digits)) {
        final newCandidates = _assign(tmpCandidates, cell, val);

        // Fail if we can't assign val to cell
        if (newCandidates == null) {
          return null;
        }
      }
    }

    return tmpCandidates;
  }
}
