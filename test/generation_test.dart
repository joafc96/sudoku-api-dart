import 'dart:math';

import 'package:sudoku_dart/src/base_puzzle.dart';
import 'package:sudoku_dart/src/generator.dart';
import 'package:sudoku_dart/src/model/cell_model.dart';
import 'package:sudoku_dart/src/model/grid_model.dart';
import 'package:sudoku_dart/src/model/position_model.dart';
import 'package:sudoku_dart/src/puzzle.dart';
import 'package:sudoku_dart/src/core/enums.dart';

import 'package:test/test.dart';

void main() {
  group('Cell Generation =>', () {
    const String cellCreationWithRC = "Test cell creation with row and column";
    test(cellCreationWithRC, () {
      final firstCell = Cell(Position(row: 0, column: 0));
      expect(firstCell.position!.index, 0);
    });

    const String cellCreationWithIndex = "Test cell creation with index";
    test(cellCreationWithIndex, () {
      final firstCell = Cell(Position(index: 0));
      expect(firstCell.position!.index, 0);
      expect(firstCell.position!.grid, const Point(0, 0));
    });

    const String cellIsPristine = 'Test newly created cell is pristine';
    test(cellIsPristine, () {
      final firstCell = Cell(Position(index: 0));

      expect(firstCell.isPristine, true);
    });

    const String cellIsValid = 'Test newly created cell is valid';
    test(cellIsValid, () {
      final firstCell = Cell(Position(index: 0));
      expect(firstCell.isValid, false);
    });

    const String cellStreamEmit =
        'Test cell stream should emit the same cell with value updated';
    test(cellStreamEmit, () {
      final firstCell = Cell(Position(index: 0));

      firstCell.change.listen(expectAsync1((emittedCell) {
        expect(emittedCell, firstCell);
        expect(emittedCell.value, 1);
      }));

      firstCell.setValue = 1;
    });

    const String segmentGridPosition =
        'Test segment of grid position (0,1) shoould be (0,0)';
    test(segmentGridPosition, () {
      final firstCell = Cell(Position(row: 0, column: 1));
      expect(firstCell.position!.segment, const Point(0, 0));
    });
  });

  group('Grid generation =>', () {
    late Grid grid;

    setUp((() {
      grid = Grid();
      grid.startListeningToCells();
    }));

    const String generatedGridPositions =
        'Test grid generated should have correct positions';
    test(generatedGridPositions, () {
      expect(grid.matrix.first.last.position!.grid, const Point(0, 8));
      expect(grid.matrix.first.last.position!.index, 8);
    });

    const String gridStreamEmit =
        'Test grid stream should emit the same cell which the value was updated';
    test(gridStreamEmit, () {
      grid.change.listen(expectAsync1((emittedCell) {
        expect(emittedCell.value, 1);
        expect(emittedCell.position!.grid, const Point(8, 8));
      }));

      grid.matrix.last.last.setValue = 1;
    });
  });

  group('Board Generation =>', () {
    late Generator sudokuGenerator;

    setUp((() {
      sudokuGenerator = Generator();
      sudokuGenerator.generate(MatrixDifficulty.evil);
    }));

    const String unsolvedBoardLength =
        'Test board length of unsolved board generated.';
    test(unsolvedBoardLength, () {
      expect(sudokuGenerator.unsolvedBoard.length, 81);
    });

    const String solvedBoardLength =
        'Test board length of solved board generated.';

    test(solvedBoardLength, () {
      expect(sudokuGenerator.solvedBoard.length, 81);
    });
  });

  group('Puzzle Generation ==>', () {
    late BasePuzzle puzzle;

    setUp((() {
      puzzle = Puzzle(MatrixDifficulty.evil);
      puzzle.generatePuzzle();
    }));

    const String testPuzzleBoardValueChange =
        'Test on board change handler of puzzle board when cell value is updated.';

    test(testPuzzleBoardValueChange, () {
      puzzle.onBoardChange((cell) {
        expect(cell.value, 8);
      });

      puzzle.unsolvedBoard()!.matrix.first.first.setValue = 8;
    });

    const String testPuzzleCellIsPristineBefore =
        'Test on board cell whether is in original condition before cell value updation (isPristine).';
    test(testPuzzleCellIsPristineBefore, () {
      puzzle.onBoardChange((cell) {
        expect(puzzle.unsolvedBoard()!.matrix.first.first.isPristine, true);
      });
    });

    const String testPuzzleCellIsPristineAfter =
        'Test on board cell whether is in original condition after cell value updation (isPristine).';
    test(testPuzzleCellIsPristineAfter, () {
      puzzle.onBoardChange((cell) {
        expect(cell.isPristine, false);
      });

      puzzle.unsolvedBoard()!.matrix.first.first.setValue = 8;
    });

    const String testPuzzleCellIsValid =
        'Test on board cell whether the value is valid after updation.';
    test(testPuzzleCellIsValid, () {
      puzzle.onBoardChange((cell) {
        expect(puzzle.isValid(cell), false);
      });

      puzzle.unsolvedBoard()!.matrix.first.first.setValue = 8;
    });

    tearDown(() {
      puzzle.dispose();
    });
  });
}
