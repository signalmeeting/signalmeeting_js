import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'messageModel.g.dart';

@JsonSerializable(nullable: true)
class MessageModel {
  String sender;
  String text;
  DateTime time;
  @override
  bool operator ==(Object other) => other is MessageModel && time == other.time;
  @override
  int get hashCode => time.hashCode;

  MessageModel();
  factory MessageModel.fromJson(Map<String, dynamic> json) => _$MessageModelFromJson(json);
  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  get timeString => DateFormat('aa hh:mm','ko').format(time.toLocal());
  
  @override
  String toString() {
    return toJson().toString();
  }
}