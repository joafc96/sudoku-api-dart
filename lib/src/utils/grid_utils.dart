import '../model/cell_model.dart';
import '../model/grid_model.dart';
import '../model/position_model.dart';

class GridUtils {
  const GridUtils._internal();

  /// Performs a DEEP clone of a grid
  /// When talking about cloning, it (mostly) boils down to two types;
  /// Shallow: Constructs new object in new member space, but inserts references
  ///          for as many of that objects fields as possible.
  /// Deep:    Constructs a new object in new memory space, along with new objects
  ///          for all fields within that object.
  static Grid deepClone(Grid? source) {
    Grid clone = Grid();

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        clone.matrix[r][c].setValidity = source!.matrix[r][c].isValid;
        clone.matrix[r][c].setPristine = source.matrix[r][c].isPristine;
        // target.matrix![r][c].addMarkupSet(source.matrix![r][c].getMarkup()!);
        clone.matrix[r][c].setValue = source.matrix[r][c].value;
        clone.matrix[r][c].setPrefilled = source.matrix[r][c].isPrefilled;
      }
    }
    return clone;
  }

  /// Returns a copy of the provided [sudoku] as a 1 Dimensional [List].
  ///
  /// [InvalidSudokuConfigurationException] is thrown if the configuration of
  /// the [sudoku] is not valid.
  static List<Cell> to1D(List<List<Cell>> sudoku2D) {
    var sudoku1D = List.generate(81, (i) => Cell(Position(index: 0)));
    var index = 0;
    for (var i = 0; i < 9; i++) {
      for (var j = 0; j < 9; j++) {
        sudoku1D[index] = sudoku2D[i][j];
        index++;
      }
    }
    return sudoku1D;
  }

  /// Returns a copy of the provided [sudoku] as a 2 Dimensional [List] which
  /// is the standard format.
  ///
  /// [InvalidSudokuConfigurationException] is thrown if the configuration of
  /// the [sudoku] is not valid.
  static List<List<Cell>> to2D(List<Cell> sudoku1D) {
    var sudoku2D = List.generate(
        9, (i) => List.generate(9, (j) => Cell(Position(index: 0))));
    var index = 0;
    try {
      for (var i = 0; i < 9; i++) {
        for (var j = 0; j < 9; j++) {
          sudoku2D[i][j] = sudoku1D[index];
          index++;
        }
      }
    } on RangeError {
      throw RangeError("Invalid range");
    }

    return sudoku2D;
  }
}
