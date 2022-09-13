import 'position_model.dart';

abstract class ICell {
  // Position of the cell in a 9x9 grid
  Position? _position;

  // Whether this cell's value has been changed since grid generation (default true)
  bool? _isPristine;

  ICell(this._position, this._isPristine);

  Position? get position => _position;

  bool? get isPristine => _isPristine;
  set setPristine(bool? pristine) => _isPristine = pristine;
}
