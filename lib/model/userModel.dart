import 'package:json_annotation/json_annotation.dart';

part 'userModel.g.dart';

@JsonSerializable(nullable: true)
class UserModel {
  String uid;
  String phone;
  String authCode;
  int coin;
  bool stop;
  Map<dynamic, dynamic> profileInfo;
  Map<dynamic, dynamic> pushInfo;
  bool invite;
  List<Map<String, dynamic>> banList = []; //[{'from' : 'id', 'to' : 'id', 'time' : 'date'}, ...]

  UserModel(
      {this.uid,
      this.phone,
      this.authCode,
      this.coin,
      this.stop,
      this.profileInfo,
      this.invite,
      this.banList,
      });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  static UserModel initUser() {
    return new UserModel(phone: '', coin: 0, stop: false, profileInfo: {"pics": []}, invite: false, banList: []);
  }

  @override
  bool operator ==(Object other) => other is UserModel && uid == other.uid;

  @override
  int get hashCode => uid.hashCode;

  bool get man => profileInfo['man'];

  String get name => profileInfo['name'] ?? '';

  String get age => profileInfo['age'].toString();

  String get tall => profileInfo['tall'].toString();

  String get career => profileInfo['career'];

  String get loc1 => profileInfo['loc1'] ?? ''; //군희 loc1 로 바뀜
  String get loc2 => profileInfo['loc2'] ?? ''; //군희 loc2 로 바뀜

  String get bodyType => profileInfo['bodyType'];

  String get smoke => profileInfo['smoke'];

  String get drink => profileInfo['drink'];

  String get religion => profileInfo['religion'];

  String get mbti => profileInfo['mbti'];

  String get introduce => profileInfo['introduce'];

  List get pics => profileInfo['pics']??[];

  String get firstPic => profileInfo["pics"][0];

  String get phoneNumber => '0' + phone.substring(3);

  String get deviceToken => pushInfo == null ? '' : pushInfo['deviceToken'] ?? '';

  @override
  String toString() {
    return toJson().toString();
  }
}
