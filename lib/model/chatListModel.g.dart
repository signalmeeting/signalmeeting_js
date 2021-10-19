// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatListModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatListModel _$ChatListModelFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id']);
  return ChatListModel()
    ..id = json['id'] as String
    ..type = json['type'] as int
    ..link = json['link'] as String
    ..oppositeId = json['oppositeId'] as String
    ..oppositePic = json['oppositePic'] as String
    ..oppositeName = json['oppositeName'] as String
    ..time = json['time'] as String;
}

Map<String, dynamic> _$ChatListModelToJson(ChatListModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'link': instance.link,
      'oppositeId': instance.oppositeId,
      'oppositePic': instance.oppositePic,
      'oppositeName': instance.oppositeName,
      'time': instance.time,
    };
