import 'dart:math';

import '../core/constants.dart';

///           SEG0    SEG1    SEG2
///          0 1 2   3 4 5   6 7 8
///        -------------------------
///      0 | 0 0 0 | 0 0 0 | 0 0 0 |
/// SEG0 1 | 0 0 0 | 0 0 0 | 0 0 0 |
///      2 | 0 0 0 | 0 0 0 | 0 0 0 |
///        -------------------------
///      3 | 0 0 0 | 0 0 0 | 0 0 0 |
/// SEG1 4 | 0 0 0 | 0 0 0 | 0 0 0 |
///      5 | 0 0 0 | 0 0 0 | 0 0 0 |
///        -------------------------
///      6 | 0 0 0 | 0 0 0 | 0 0 0 |
/// SEG2 7 | 0 0 0 | 0 0 0 | 0 0 0 |
///      8 | 0 0 0 | 0 0 0 | 0 0 0 |

class Position {
  // Position of cell in the grid in range [[0,0]..[8,8]]
  Point? _grid;

  // Position of cell in the segment
  Point? _segment;

  // Index of the cell in range [0-80]
  int? _index;

  // Label of the cell in range [A1-I9]
  String? _label;

  Position({int row = -1, int column = -1, int index = -1}) {
    // if index is specified.
    if (index != -1) {
      _grid = Point(
          _calculateRowFromIndex(index), _calculateColumnFromIndex(index));
      _segment =
          _calculateSegmentFromGridPosition(_grid!.x.toInt(), _grid!.y.toInt());
      setIndex = index;
      _label = rows[_grid!.x.toInt()] + cols[_grid!.y.toInt()];
      // if row and column are specified. Row and Column are m(rows) and n(columns) in a matrix (mxn)
    } else if (row != -1 && column != -1) {
      _grid = Point(row, column);
      _segment = _calculateSegmentFromGridPosition(row, column);
      setIndex = _calculateIndex(row, column);
      _label = rows[row] + cols[column];
    } else {
      throw UnimplementedError(
          "Cannot generate Position without row/column, or cell index");
    }
  }

  int _calculateIndex(int row, int column) => (row * columnSize) + column;

  int _calculateRowFromIndex(int index) => (index / columnSize).floor();

  int _calculateColumnFromIndex(int index) => index % columnSize;

  Point _calculateSegmentFromGridPosition(int row, int column) =>
      Point((row / 3).floor(), (column / 3).floor());


/// Getters & Setters
  Point? get grid => _grid;

  Point? get segment => _segment;

  String? get label => _label;

  int? get index => _index;
  set setIndex(int? index) {
    if (index! >= 0 && index <= 80) {
      _index = index;
    } else {
      throw RangeError(
          "Index of cell out of range, should be in between 0 and 80");
    }
  }

  /// Determine if position is valid via simple range check of [index]
  bool isValid() {
    if (index! < 0 || index! > 80) {
      return true;
    }
    return false;
  }
}
