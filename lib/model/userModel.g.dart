// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'userModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return UserModel(
    uid: json['uid'] as String,
    phone: json['phone'] as String,
    authCode: json['authCode'] as String,
    coin: json['coin'] as int,
    stop: json['stop'] as bool,
    profileInfo: json['profileInfo'] as Map<String, dynamic>,
    invite: json['invite'] as bool,
    banList: (json['banList'] as List)
        ?.map((e) => e as Map<String, dynamic>)
        ?.toList(),
    free: json['free'],
    dailyMeetingActivation: json['dailyMeetingActivation'] as bool,
  )..pushInfo = json['pushInfo'] as Map<String, dynamic>;
}

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'uid': instance.uid,
      'phone': instance.phone,
      'authCode': instance.authCode,
      'coin': instance.coin,
      'stop': instance.stop,
      'profileInfo': instance.profileInfo,
      'pushInfo': instance.pushInfo,
      'invite': instance.invite,
      'banList': instance.banList,
      'free': instance.free,
      'dailyMeetingActivation': instance.dailyMeetingActivation,
    };
