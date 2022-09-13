import 'dart:async';

import 'icell.dart';

class Cell extends ICell {
  // Value of the cell in range [1-9]
  int? _value;

  // Does this cell have a value initially
  bool? _isPrefilled;

  // Does this cell match its solution counterpart?
  bool? _isValid;

  // Emits the cell isntance when the value is updated
  late StreamController<Cell> _onChange;

  Cell(position, [this._value = 0]) : super(position, true) {
    _isPrefilled = _value != 0;
    _isValid = _isPrefilled;

    _onChange = StreamController.broadcast();
  }

  void clear() {
    _value = 0;
    setPristine = true;
    _isPrefilled = false;
    _isValid = false;
  }

  /// Equitable cells, determined by position
  @override
  bool operator ==(dynamic obj) {
    if (obj is Cell && obj.position == position) {
      return true;
    }
    return false;
  }

  @override
  int get hashCode => position.hashCode;

  @override
  toString() {
    return "${position!.label}";
  }

  /// Getters and Setters
  
  int? get value => _value;
  set setValue(
    int? value,
  ) {
    if (value! >= 1 && value <= 9) {
      _value = value;
      setPristine = false;
      _onChange.add(this);
    } else {
      throw RangeError(
          "Value of cell out of range, should be in between 1 and 9");
    }
  }

  bool? get isPrefilled => _isPrefilled;
  set setPrefilled(bool? prefilled) => _isPrefilled = prefilled;

  bool? get isValid => _isValid;
  set setValidity(bool? valid) => _isValid = valid;

  Stream<Cell> get change => _onChange.stream.asBroadcastStream();
}
