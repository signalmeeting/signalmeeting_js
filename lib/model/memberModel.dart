import 'package:json_annotation/json_annotation.dart';

part 'memberModel.g.dart';

@JsonSerializable(nullable: true)
class MemberModel {
  int age;
  int tall;
  String career;
  String loc1;
  String loc2;
  String bodyType;
  String smoke;
  String drink;
  String mbti;
  String introduce;


  MemberModel({
    this.age,
    this.tall,
    this.career,
    this.loc1,
    this.loc2,
    this.bodyType,
    this.smoke,
    this.drink,
    this.mbti,
    this.introduce,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) => _$MemberModelFromJson(json);

  Map<String, dynamic> toJson() => _$MemberModelToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
