import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'alarmModel.g.dart';

@JsonSerializable(nullable: true)
class AlarmModel {
  String id;
  String type; // signal (toMe), match
  String body; // 내용
  DateTime time;
  @override
  bool operator ==(Object other) => other is AlarmModel && id == other.id;
  @override
  int get hashCode => id.hashCode;

  AlarmModel();
  factory AlarmModel.fromJson(Map<String, dynamic> json) => _$AlarmModelFromJson(json);
  Map<String, dynamic> toJson() => _$AlarmModelToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

  String get date => DateFormat('yyyy.MM.dd').format(time);
}