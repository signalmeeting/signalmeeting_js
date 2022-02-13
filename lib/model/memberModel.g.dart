// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memberModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemberModel _$MemberModelFromJson(Map<String, dynamic> json) {
  return MemberModel(
    age: json['age'] as int,
    tall: json['tall'] as int,
    career: json['career'] as String,
    loc1: json['loc1'] as String,
    loc2: json['loc2'] as String,
    bodyType: json['bodyType'] as String,
    smoke: json['smoke'] as String,
    drink: json['drink'] as String,
    mbti: json['mbti'] as String,
    introduce: json['introduce'] as String,
  );
}

Map<String, dynamic> _$MemberModelToJson(MemberModel instance) =>
    <String, dynamic>{
      'age': instance.age,
      'tall': instance.tall,
      'career': instance.career,
      'loc1': instance.loc1,
      'loc2': instance.loc2,
      'bodyType': instance.bodyType,
      'smoke': instance.smoke,
      'drink': instance.drink,
      'mbti': instance.mbti,
      'introduce': instance.introduce,
    };
