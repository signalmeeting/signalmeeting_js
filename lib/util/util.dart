import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:byule/model/memberModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:byule/ui/widget/dialog/main_dialog.dart';
import 'package:byule/ui/widget/dialog/notification_dialog.dart';

class Util {

  static todayMatchDateFormat(DateTime date) => DateFormat('yyyyMMdd').format(date);

  static coinLogDateFormat(DateTime date) => DateFormat('yyyy-MM-dd HH:mm').format(date);

  static dateFormat(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  static getListElement(List list,int index) {
    if (list.length <= index || list == null) return null;
    else return list[index];
  }

  static replaceListElement(List list, int index, object) {
    if (list.length <= index || list == null) {
      return null;
    }
    list.removeAt(index);
    list.insert(index, object);
  }
  
  static mapMembers(dynamic memberList) {
    if(memberList !=null && memberList.length >0) {
      Map<String, dynamic> memberMap = memberList;
      memberList = memberMap.values.map((e) => e).toList();
      return memberList;
    } else return [];
  }

  static MemberModel userToMemberModel(Map<dynamic, dynamic> profileInfo) => MemberModel(
    index: null,
    url: profileInfo['pics'][0],
    age: profileInfo['age'].toString(),
    tall: profileInfo['tall'].toString(),
    career: profileInfo['career'],
    loc1: profileInfo['loc1'],
    loc2: profileInfo['loc2'],
    bodyType: profileInfo['bodyType'],
    smoke: profileInfo['smole'],
    drink: profileInfo['drink'],
    mbti: profileInfo['mbti'],
    introduce: profileInfo['introduce'],
  );
  
  static getImage() async {
    final image = await ImagePicker()
        .getImage(source: ImageSource.gallery, imageQuality: 50);
    if (image != null) {
      File croppedFile = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatioPresets: [CropAspectRatioPreset.square],
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: '사진편집',
              toolbarColor: Colors.blue[200],
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: true),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));
      return Future<File>.value(croppedFile);
    }
    return Future<File>.value(null);
  }


  static String getRandString(int len) {
    var random = Random.secure();
    var values = List<int>.generate(len, (i) =>  random.nextInt(255));
    return base64UrlEncode(values);
  }
}
