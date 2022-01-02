import 'dart:ui';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:byule/controller/main_controller.dart';
import 'package:byule/services/database.dart';
import 'package:byule/ui/widget/flush_bar.dart';
import 'package:byule/util/style/appColor.dart';
import 'package:byule/util/style/btStyle.dart';

class InviteFriendsPage extends StatefulWidget {
  @override
  _InviteFriendsPageState createState() => _InviteFriendsPageState();
}

class _InviteFriendsPageState extends State<InviteFriendsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _targetUIDController = TextEditingController();

  final MainController _controller = Get.find();

  String get myUID => _controller.user.value.uid.substring(0,10);

  bool get firstTime => !(_controller.user.value.invite ?? false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            highlightColor: Colors.white,
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          centerTitle: true,
          title: Text(
            '친구초대',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        body: Stack(
          children: <Widget>[
            Container(
              color: Colors.white,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                //"추천시 양측 모두 50하트씩 지급"
                TextBox1(),
                //추천인코드 입력
                TextBox2(),
                Obx(
                  () => Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 20, right: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              height: 58,
                              child: TextFormField(
                                onChanged: (text) => setState(() {}),
                                controller: _targetUIDController,
                                decoration: InputDecoration(
                                  // contentPadding: new EdgeInsets.fromLTRB(10, 20, 0, 20),
                                  fillColor: Colors.white,
                                  filled: true,
                                  enabled: firstTime,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: AppColor.sub200, width: 1),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey, width: 1),
                                  ),
                                  border: OutlineInputBorder(),
                                  labelStyle: TextStyle(color: Colors.grey),
                                  labelText: firstTime ? '상대방 추천인코드' : '친구초대 완료',
                                ),
                                cursorColor: AppColor.sub100,
                                validator: (value) {
                                  return '알맞은 코드를 입력해주세요';
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            height: 58,
                            width: 90,
                            child: TextButton(
                              child: Text(
                                '입력',
                              ),
                              style: BtStyle.textSub200,
                              onPressed: firstTime && _targetUIDController.text.length == 10
                                  ? () async {
                                      bool result = await DatabaseService.instance.inviteFriend(_targetUIDController.text);
                                      if (result) {
                                        //한번만 입력 가능하게
                                        _controller.finishInvite();

                                        //완료 스낵바
                                        CustomedFlushBar(Get.context, "입력이 완료되었습니다");
                                      } else {
                                        _formKey.currentState.validate();
                                      }
                                      //키보드 창 내리고 flush 띄움
                                      FocusScope.of(context).unfocus();
                                    }
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                //나의 추천인코드
                TextBox3(),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 20, right: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          height: 58,
                          child: TextFormField(
                            enabled: false,
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 1),
                              ),
                              border: OutlineInputBorder(),
                              labelStyle: TextStyle(color: Colors.grey),
                              labelText: '$myUID',
                            ),
                            cursorColor: Colors.blue[100],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        height: 58,
                        width: 90,
                        child: TextButton(
                          child: Text('복사',
                          ),
                          style: BtStyle.start,
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: '$myUID'));
                            CustomedFlushBar(Get.context, "복사 되었습니다");
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  Widget TextBox1() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Text.rich(TextSpan(style: TextStyle(fontSize: 18), children: <TextSpan>[
            TextSpan(
              text: '"추천시 양측 모두 ',
            ),
            TextSpan(
              text: '50 하트씩 ',
              style: TextStyle(
                color: AppColor.sub,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: '지급"',
            ),
          ])),
        ),
        Container(
          height: 10,
          color: Colors.grey[200],
        ),
      ],
    );
  }

  Widget TextBox2() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 30,
        ),
        Text(
          '추천인코드 입력',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        Text(
          '(1회 가능)',
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }

  Widget TextBox3() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 30,
        ),
        Text(
          '나의 추천인코드',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        Text(
          '(무제한 가능)',
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}
