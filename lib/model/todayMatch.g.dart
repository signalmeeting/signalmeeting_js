// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todayMatch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodayMatch _$TodayMatchFromJson(Map<String, dynamic> json) {
  return TodayMatch(
    documentId: json['documentId'] as String,
    sameGenders: (json['sameGenders'] as List)
        ?.map((e) =>
            e == null ? null : UserModel.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    oppositeGenders: (json['oppositeGenders'] as List)
        ?.map((e) =>
            e == null ? null : UserModel.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$TodayMatchToJson(TodayMatch instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'sameGenders': instance.sameGenders,
      'oppositeGenders': instance.oppositeGenders,
    };
