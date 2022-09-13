import 'dart:async';

import '../core/constants.dart';

import 'cell_model.dart';
import 'position_model.dart';

class Grid {  
  // Represents the matrix with cells in it (9x9)
  List<List<Cell>> _matrix = [];

  // Emits the cell which the value was updated
  late StreamController<Cell> _onChange;

  // List of stream subs to listen all the cells streams
  late List<StreamSubscription<Cell>> _cellStreamSubscriptions;

  Cell cellAt(Position position) =>
      _matrix[position.grid!.x as int][position.grid!.y as int];

  Grid() {
    _matrix = List.generate(
        columnSize,
        (_) =>
            List.filled(columnSize, Cell(Position(index: 0)), growable: false),
        growable: false);
    _buildInitialMatrix();
  }

  /// Constructs a matrix of cells whose value is all empty
  _buildInitialMatrix() {
    for (int m = 0; m < rowSize; m++) {
      for (int n = 0; n < columnSize; n++) {
        _matrix[m][n] = Cell(Position(row: m, column: n));
      }
    }
  }

  /// Attach listeners for each cell - the grid is now listening for changes to
  /// any cell, and will broadcast them through [_onChange]
  void startListeningToCells() {
    _cellStreamSubscriptions = [];
    _onChange = StreamController.broadcast();

    for (int m = 0; m < rowSize; m++) {
      for (int n = 0; n < columnSize; n++) {
        _cellStreamSubscriptions.add(
          _matrix[m][n].change.listen(
                (cell) => _onChange.add(cell),
              ),
        );
      }
    }
  }

  /// Detach all subscriptions to cell streams - stop listening to changes
  void stopListeningCells() {
    for (StreamSubscription sub in _cellStreamSubscriptions) {
      sub.cancel();
    }
  }

  List<Cell> getRow(int rowNum) {
    return _matrix[rowNum];
  }

  List<Cell> getColumn(int colNum) {
    List<Cell> tmpCol = [];
    for (int c = 0; c < 9; c++) {
      tmpCol.add(_matrix[c][colNum]);
    }

    return tmpCol;
  }

  List<Cell> getSegment(Position position) {
    List<Cell> tmpSeg = [];
    for (int rInc = 0; rInc < 3; rInc++) {
      for (int cInc = 0; cInc < 3; cInc++) {
        tmpSeg.add(_matrix[(position.segment!.x * 3) + rInc as int]
            [(position.segment!.y * 3) + cInc as int]);
      }
    }

    return tmpSeg;
  }

  /// Getters and Setters
  List<List<Cell>> get matrix => _matrix;
  Stream<Cell> get change => _onChange.stream.asBroadcastStream();
  set setMatrix(List<List<Cell>> matrix) {
    _matrix = matrix;
  }
}
