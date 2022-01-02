// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meetingModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingModel _$MeetingModelFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['_id']);
  return MeetingModel()
    ..id = json['_id'] as String
    ..man = json['man'] as bool
    ..title = json['title'] as String
    ..user = firestoreDocRefFromJson(json['user'])
    ..userId = json['userId'] as String
    ..number = json['number'] as int
    ..loc1 = json['loc1'] as String
    ..loc2 = json['loc2'] as String
    ..loc3 = json['loc3'] as String
    ..introduce = json['introduce'] as String
    ..phone = json['phone'] as String
    ..isMine = json['isMine'] as bool
    ..process = json['process'] as int
    ..apply = json['apply'] == null
        ? null
        : ApplyModel.fromJson(json['apply'] as Map<String, dynamic>)
    ..applyUser = json['applyUser'] == null
        ? null
        : UserModel.fromJson(json['applyUser'] as Map<String, dynamic>)
    ..createdAt = json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String)
    ..meetingImageUrl = json['meetingImageUrl'] as String
    ..banList = (json['banList'] as List)
        ?.map((e) => e as Map<String, dynamic>)
        ?.toList();
}

Map<String, dynamic> _$MeetingModelToJson(MeetingModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'man': instance.man,
      'title': instance.title,
      'user': firestoreDocRefToJson(instance.user),
      'userId': instance.userId,
      'number': instance.number,
      'loc1': instance.loc1,
      'loc2': instance.loc2,
      'loc3': instance.loc3,
      'introduce': instance.introduce,
      'phone': instance.phone,
      'isMine': instance.isMine,
      'process': instance.process,
      'apply': instance.apply,
      'applyUser': instance.applyUser,
      'createdAt': instance.createdAt?.toIso8601String(),
      'meetingImageUrl': instance.meetingImageUrl,
      'banList': instance.banList,
    };
