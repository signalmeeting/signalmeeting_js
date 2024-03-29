// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messageModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) {
  return MessageModel()
    ..sender = json['sender'] as String
    ..receiver = json['receiver'] as String
    ..text = json['text'] as String
    ..type = json['type'] as String
    ..time =
        json['time'] == null ? null : DateTime.parse(json['time'] as String)
    ..showDate = json['showDate'] as bool ?? false;
}

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      'sender': instance.sender,
      'receiver': instance.receiver,
      'text': instance.text,
      'type': instance.type,
      'time': instance.time?.toIso8601String(),
      'showDate': instance.showDate,
    };
