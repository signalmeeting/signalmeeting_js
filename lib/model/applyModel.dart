import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:byule/model/meetingModel.dart';

part 'applyModel.g.dart';

@JsonSerializable(nullable: true)
class ApplyModel {

  String applyId;
  String msg;
  String phone;
  @JsonKey(fromJson: firestoreDocRefFromJson, toJson: firestoreDocRefToJson)
  DocumentReference user;
  String userId;

  ApplyModel({this.applyId, this.msg, this.phone, this.user, this.userId});

  factory ApplyModel.fromJson(Map<String, dynamic> json) => _$ApplyModelFromJson(json);
  Map<String, dynamic> toJson() => _$ApplyModelToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
