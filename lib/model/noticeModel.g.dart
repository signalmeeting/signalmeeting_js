// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'noticeModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoticeModel _$NoticeModelFromJson(Map<String, dynamic> json) {
  return NoticeModel()
    ..id = json['id'] as String
    ..title = json['title'] as String
    ..body = json['body'] as String
    ..time =
        json['time'] == null ? null : DateTime.parse(json['time'] as String);
}

Map<String, dynamic> _$NoticeModelToJson(NoticeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'time': instance.time?.toIso8601String(),
    };
