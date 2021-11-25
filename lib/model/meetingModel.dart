
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jiffy/jiffy.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:signalmeeting/model/userModel.dart';

part 'meetingModel.g.dart';

DocumentReference firestoreDocRefFromJson(dynamic value) {
  if (value is DocumentReference) {
    return FirebaseFirestore.instance.doc(value.path);
  } else if (value is String) {
    return FirebaseFirestore.instance.doc(value);
  }
  return null;
}

dynamic firestoreDocRefToJson(dynamic value) => value;

@JsonSerializable(nullable: true)
class MeetingModel {
  @JsonKey(name: '_id', required: true)
  String id;
  bool man; //인창, 추가
  String title;
  @JsonKey(fromJson: firestoreDocRefFromJson, toJson: firestoreDocRefToJson)
  DocumentReference user; // user uid
  String userId;
  int number;
  String loc1;
  String loc2;
  String loc3;
  String introduce;
  String phone;
  bool isMine = false; // 내가 만들었으면 true
  int process; // null: 신청 가능 0: 신청중, 1: 연결, 2: 거절 (null 이거나 2 이면 신청 가능)
  Map<dynamic, dynamic> apply; //msg, createdAt, id, +phone
  UserModel applyUser;
  DateTime date;
  String meetingImageUrl;
  MeetingModel();
  List<Map<String, dynamic>> banList = [];
  @JsonKey(ignore: true)
  DateTime deletedTime;

  factory MeetingModel.fromJson(Map<String, dynamic> json) => _$MeetingModelFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingModelToJson(this);

  @override
  bool operator ==(Object other) => other is MeetingModel && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return toJson().toString();
  }

  String get monthDate => Jiffy(date, "yyyy.MM.dd").format("MM.dd");
}
