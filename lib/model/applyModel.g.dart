// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'applyModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApplyModel _$ApplyModelFromJson(Map<String, dynamic> json) {
  return ApplyModel(
    applyId: json['applyId'] as String,
    msg: json['msg'] as String,
    phone: json['phone'] as String,
    user: firestoreDocRefFromJson(json['user']),
    userId: json['userId'] as String,
  )..memberList = (json['memberList'] as List)
      ?.map((e) =>
          e == null ? null : MemberModel.fromJson(e as Map<String, dynamic>))
      ?.toList();
}

Map<String, dynamic> _$ApplyModelToJson(ApplyModel instance) =>
    <String, dynamic>{
      'applyId': instance.applyId,
      'msg': instance.msg,
      'phone': instance.phone,
      'user': firestoreDocRefToJson(instance.user),
      'userId': instance.userId,
      'memberList': instance.memberList,
    };
