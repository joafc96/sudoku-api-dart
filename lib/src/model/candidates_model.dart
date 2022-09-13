import 'package:json_annotation/json_annotation.dart';

part 'candidates_model.g.dart';

@JsonSerializable()
class Candidates {
  // Contains the cells as keys and the possible values (digits) the cell can hold as values
  Map<String, String> candidatesMap;

  Candidates({
    this.candidatesMap = const {},
  });

  factory Candidates.fromJson(Map<String, dynamic> json) =>
      _$CandidatesFromJson(json);

  Map<String, dynamic> toJson() => _$CandidatesToJson(this);
}
