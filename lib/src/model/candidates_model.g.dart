// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candidates_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Candidates _$CandidatesFromJson(Map<String, dynamic> json) => Candidates(
      candidatesMap: (json['candidatesMap'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$CandidatesToJson(Candidates instance) =>
    <String, dynamic>{
      'candidatesMap': instance.candidatesMap,
    };
