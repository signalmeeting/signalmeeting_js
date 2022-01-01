import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:json_annotation/json_annotation.dart';

part 'messageModel.g.dart';

@JsonSerializable(nullable: true)
class MessageModel {
  String sender;
  String receiver;
  String text;
  String type; //meeting or signal
  DateTime time;
  @JsonKey(defaultValue: false)
  bool showDate;
  @override
  bool operator ==(Object other) => other is MessageModel && time == other.time;
  @override
  int get hashCode => time.hashCode;

  MessageModel();
  factory MessageModel.fromJson(Map<String, dynamic> json) => _$MessageModelFromJson(json);
  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  String get timeString => DateFormat('aa hh:mm','ko').format(time.toLocal());
  String get theDay => Jiffy(time).format('yyyy년 MM월 dd일');
  
  @override
  String toString() {
    return toJson().toString();
  }
}