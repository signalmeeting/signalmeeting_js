import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:byule/controller/main_controller.dart';
import 'package:byule/model/userModel.dart';
import 'package:byule/services/database.dart';
import 'package:byule/ui/lobby.dart';
import 'package:byule/ui/widget/dialog/confirm_dialog.dart';
import 'package:byule/ui/widget/dialog/notification_dialog.dart';
import 'package:byule/ui/widget/flush_bar.dart';
import 'package:byule/main.dart';
import 'package:byule/util/style/btStyle.dart';

import 'custom_drawer.dart';

class InquiryPage extends StatefulWidget {
  @override
  _InquiryPageState createState() => _InquiryPageState();
}

class _InquiryPageState extends State<InquiryPage> {
  final MainController _controller = Get.find();

  @override
  void initState() {
    if (this.mounted && _controller.user.value.stop)
      1.delay(() {
        Get.dialog(NotificationDialog(
          contents: "정지당한 계정입니다.",
        ));
      });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: drawerAppBar(context, '문의 및 계정'),
      body: Stack(
        children: <Widget>[
          Container(
            color: Colors.white,
          ),
          Column(
            children: <Widget>[
              //텍스트
              TextBox(context),
              //로그 아웃
              TextButton(
                child: Text(
                  '로그아웃',
                ),
                style: BtStyle.textSub200,
                onPressed: () {
                  Get.dialog(
                    ConfirmDialog(
                      title: '로그 아웃',
                      text: '로그 아웃 하시겠습니까?',
                      //onConfirmed: () => _lobbyController.isLogOut.update((val) { val = !val;}),
                      onConfirmed: () => logOut(context),
                      confirmText: '확인',
                    ),
                  );
                },
              ),
              SizedBox(height: 10),
              //회원 탈퇴
              TextButton(
                child: Text(
                  '회원탈퇴',
                ),
                style: BtStyle.textSub100,
                onPressed: () {
                  Get.dialog(
                    ConfirmDialog(
                      title: '회원 탈퇴',
                      text: '21일간 재가입 불가하며,\n탈퇴하시면 복구가 불가능합니다.\n정말로 탈퇴하시겠습니까?',
                      onConfirmed: () {
                        Get.dialog(Center(child: CircularProgressIndicator()));
                        DatabaseService.instance.withDraw();
                      },
                      confirmText: '탈퇴',
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget TextBox(context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Text(
            '기타 문의 사항이 있으신 경우',
            style: TextStyle(fontSize: 17),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SelectableText(
                'signalmeeting@gmail.com',
                style: TextStyle(
                    fontSize: 17, decoration: TextDecoration.underline),
                onTap: () {
                  //클립보드로 복사
                  Clipboard.setData(
                      ClipboardData(text: 'byule@gmail.com'));

                  CustomedFlushBar(context, '이메일이 복사 되었습니다');
                },
              ),
              Text(
                '으로',
                style: TextStyle(fontSize: 17),
              ),
            ],
          ),
        ),
        Text(
          ' 문의해주시기 바랍니다',
          style: TextStyle(fontSize: 17),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 50, bottom: 20),
          child: Container(
            height: 10,
            color: Colors.grey[200],
          ),
        ),
      ],
    );
  }

  logOut(context) async {
    _controller.updateUser(UserModel.initUser());
    try {
      await FirebaseAuth.instance.signOut();
      Get.delete<LobbyController>();
      _controller.user = UserModel().obs;
      _controller.todayMatchList.clear();
      Get.offAll(() => Splash());
    } catch (e) {
      //Get.defaultDialog(title: "Error", content: Text(e.toString()));
      Get.dialog(NotificationDialog(
        contents: e.toString(),
      ));
    }
  }
}
