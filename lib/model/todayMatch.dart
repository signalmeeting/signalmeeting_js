import 'package:json_annotation/json_annotation.dart';
import 'package:byule/model/userModel.dart';

part 'todayMatch.g.dart';

@JsonSerializable(nullable: true)
class TodayMatch {
  String documentId;
  List<UserModel> sameGenders;
  List<UserModel> oppositeGenders;
  TodayMatch({this.documentId, this.sameGenders, this.oppositeGenders});
  factory TodayMatch.fromJson(Map<String, dynamic> json) => _$TodayMatchFromJson(json);
  Map<String, dynamic> toJson() => _$TodayMatchToJson(this);

  @override
  bool operator ==(Object other) => other is TodayMatch && documentId == other.documentId;
  @override
  int get hashCode => documentId.hashCode;
//
//  String get firstImage => Utility.getSafetyValue(profileInfo, key: ['pics', 0,'url']);
//  String get nickName => profileInfo['name'] ?? '';

  @override
  String toString() {
    return toJson().toString();
  }
}
