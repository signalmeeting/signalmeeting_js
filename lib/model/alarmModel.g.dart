// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarmModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlarmModel _$AlarmModelFromJson(Map<String, dynamic> json) {
  return AlarmModel()
    ..id = json['id'] as String
    ..type = json['type'] as String
    ..body = json['body'] as String
    ..time =
        json['time'] == null ? null : DateTime.parse(json['time'] as String);
}

Map<String, dynamic> _$AlarmModelToJson(AlarmModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'body': instance.body,
      'time': instance.time?.toIso8601String(),
    };
