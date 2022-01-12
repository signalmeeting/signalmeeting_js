import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:byule/controller/main_controller.dart';
import 'package:byule/model/userModel.dart';
import 'package:byule/services/database.dart';
import 'package:byule/util/util.dart';

import 'custom_drawer.dart';

class MyProfileImageEditPage extends StatefulWidget {
  @override
  _MyProfileImageEditPageState createState() => _MyProfileImageEditPageState();
}

class _MyProfileImageEditPageState extends State<MyProfileImageEditPage> {
  final MainController _controller = Get.find();

  UserModel get user => _controller.user.value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: drawerAppBar(context, '프로필 사진 수정'),
        body: Stack(
          children: [
            Container(color: Colors.white),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerRight,
                      height: Get.width * 0.60,
                      width: Get.width * 0.90,
                      child: Obx(
                        () => Row(
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: photoBox(0, Get.width * 0.60),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: photoBox(1, Get.width * 0.30),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: photoBox(2, Get.width * 0.30),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text('* 메인 사진은 필수 등록입니다.'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ));
  }

  Widget photoBox(int index, double width) {
    var pics = user.profileInfo['pics'];
    var pic = Util.getListElement(pics, index);
    return pic != null
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () => Get.dialog(PhotoDialog(index, pic)),
              child: ClipRRect(
                  borderRadius: new BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                      placeholder: (context, url) =>
                          Center(child: CircularProgressIndicator()),
                      imageUrl: pic.toString().startsWith('http')
                          ? pic.toString()
                          : (new File(pic)),
                      width: width,
                      height: width,
                      fit: BoxFit.cover)),
            ))
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () => _getImage(index),
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey)),
                  width: width,
                  height: width,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('센터', style: TextStyle(color: Colors.white)),
                        Icon(
                          Icons.add,
                          color: Colors.grey,
                        ),
                        Text(index == 0 ? '(메인 사진, 필수)' : '(옵션$index)',
                            style: TextStyle(color: Colors.grey))
                      ])),
            ),
          );
  }

  _getImage(index) async {
    File image = await Util.getImage();
    if (image != null) {
      List pics = user.profileInfo['pics'];
      String uploadedUrl = await DatabaseService.instance.uploadUserImage(image.path, index);
      var pic = Util.getListElement(pics, index);
      if (pic != null)
        Util.replaceListElement(pics, index, uploadedUrl);
      else
        pics.add(uploadedUrl);
      bool result = await DatabaseService.instance.uploadUserPic(pics);
      _controller.updateUserPics(pics);
    }
  }

  Widget PhotoDialog(index, pic) {
    return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(10),
        child: Container(
          width: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: Colors.white,
          ),
          padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Text(
                  '사진 등록',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              //사진 선택
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _getImage(index);
                },
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          '앨범에서 선택',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //사진 삭제)
              //메인 사진은 삭제 제한
              if (index != 0)
                GestureDetector(
                  onTap: () async {
                    List newPics = user.profileInfo['pics'];
                    newPics.removeAt(index);
                    print(newPics);
                    _controller.updateUserPics(newPics);
                    await DatabaseService.instance.uploadUserPic(newPics);

                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            '사진 삭제',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              //취소(나가기)
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          '취소',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
