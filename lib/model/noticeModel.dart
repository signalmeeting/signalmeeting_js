import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'noticeModel.g.dart';

@JsonSerializable(nullable: true)
class NoticeModel {
  String id;
  String title; // 0=소개팅, 1=미팅
  String body;
  DateTime time;
  @override
  bool operator ==(Object other) => other is NoticeModel && id == other.id;
  @override
  int get hashCode => id.hashCode;

  NoticeModel();
  factory NoticeModel.fromJson(Map<String, dynamic> json) => _$NoticeModelFromJson(json);
  Map<String, dynamic> toJson() => _$NoticeModelToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

  String get date => DateFormat('yyyy.MM.dd').format(time);
}