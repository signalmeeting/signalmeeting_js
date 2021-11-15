import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signalmeeting/controller/main_controller.dart';
import 'package:signalmeeting/model/userModel.dart';
import 'package:signalmeeting/util/util.dart';

import '../lobby.dart';

class StartPage4 extends StatefulWidget {
  @override
  _StartPage4State createState() => _StartPage4State();
}

class _StartPage4State extends State<StartPage4> {
  MainController _controller = Get.find();

  UserModel get user => _controller.user.value;

  @override
  Widget build(BuildContext context) {

    double width = Get.width;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            color: Colors.white,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 15.0, top: 50),
                    child: Text(
                      '사진 등록',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Obx(
                () => Container(
                      alignment: Alignment.centerRight,
                      height: width * 0.60,
                      width: width * 0.90,
                      child: Row(children: <Widget>[
                        Expanded(
                            flex: 2,
                            child: photoBox(width * 0.60, width * 0.60, 0)),
                        Expanded(
                            flex: 1,
                            child: Column(children: <Widget>[
                              Expanded(
                                  flex: 1,
                                  child: photoBox(width * 0.30, width * 0.30, 1)),
                              Expanded(
                                  flex: 1,
                                  child: photoBox(width * 0.30, width * 0.30, 2))
                            ]))
                      ])),
                ),
                NextButton(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget photoBox(width, height, int index) {

      var pics = user.profileInfo['pics'];
      var pic = Util.getListElement(pics, index);
      return pic != null
          ? Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(8.0),
            onTap: () => Get.dialog(PhotoDialog(index, pic)),
            child: ClipRRect(
                borderRadius: new BorderRadius.circular(8.0),
                child: Image(
                    image: pic.toString().startsWith('http')
                        ? NetworkImage(pic.toString())
                        : FileImage(new File(pic)),
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
                  ])),
        ),
      );
  }

  _getImage(index) async {
    File image = await Util.getImage();
    if (image != null) {
      List pics = user.profileInfo['pics'];
      var pic = Util.getListElement(pics, index);
      if (pic != null) {
        Util.replaceListElement(pics, index, {'url': image.path, 'pass': 0});
      } else
        pics.add(image.path);
      print('pic : $pic');
      _controller.updateUserPics(pics);
    }
  }

  Widget NextButton() {
    return Obx(
          () => ButtonTheme(
        padding: EdgeInsets.all(0),
        minWidth: Get.width * 0.9 - 16,
        height: 45,
        child: RaisedButton(
          child: Container(
            width: Get.width * 0.9 - 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.transparent,
                    size: 15,
                  ),
                ),
                Text(
                  '다음',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ],
            ),
          ),
          color: Colors.blue[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          onPressed: List.from(user.profileInfo['pics']).isEmpty ? null : () async {
            await _controller.newUser();
            Get.offAll(() => LobbyPage(), transition: Transition.fadeIn);
          },
        ),
      ),
    );
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
              //사진 삭제
              GestureDetector(
                onTap: () {
                  setState(() {
                    List pics = user.profileInfo['pics'];
                    pics.removeAt(index);
                    _controller.user(user..profileInfo['pics'] = pics);
                  });
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
