import 'package:json_annotation/json_annotation.dart';

part 'chatListModel.g.dart';

@JsonSerializable(nullable: true)
class ChatListModel {
  @JsonKey(name: 'id', required: true)
  String id;
  int type; // 0=소개팅, 1=미팅
  String link;
  String oppositeId;
  String oppositePic;
  String oppositeName;
  String time;
  @override
  bool operator ==(Object other) => other is ChatListModel && id == other.id;
  @override
  int get hashCode => id.hashCode;

  ChatListModel();
  factory ChatListModel.fromJson(Map<String, dynamic> json) => _$ChatListModelFromJson(json);
  Map<String, dynamic> toJson() => _$ChatListModelToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}