import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:byule/controller/main_controller.dart';
import 'package:byule/model/userModel.dart';
import 'package:byule/services/database.dart';
import 'package:byule/ui/drawer/my_profile_page.dart';
import 'package:byule/util/style/btStyle.dart';

import 'custom_drawer.dart';


class MyProfileIntroduceEditPage extends StatefulWidget {

  @override
  _MyProfileIntroduceEditPageState createState() => _MyProfileIntroduceEditPageState();
}

class _MyProfileIntroduceEditPageState extends State<MyProfileIntroduceEditPage> {
  final MainController _controller = Get.find();

  UserModel get user => _controller.user.value;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _selfIntroductionController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    //텍스트 값 유
    _selfIntroductionController.text = user.introduce;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar:drawerAppBar(context, '간단소개'),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    child: TextFormField(
                      validator: (value) {
                        if(value.length>200) {
                          return '200자 초과';
                        } return null;
                      },
                      controller: _selfIntroductionController,
                      maxLength: 200,
                      minLines: 5,
                      maxLines: 10,
                      decoration: InputDecoration(
                        hintText: user.introduce != null ?  null : '자신의 매력을 간단하게 소개해주세요.',
                        filled: true,
                        fillColor: Colors.grey[100],
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.grey[300]),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.grey[300]),
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextButton(
                            child: Text('작성 완료'),
                            style: BtStyle.textSub200,
                            onPressed: () {
                              if(_formKey.currentState.validate()) {
                                _controller.changeProfileValue('introduce', _selfIntroductionController.text);
                                Get.back();
                              }
                            }
                        ),
                      ],
                    ),
                  ),
                  Text('* 본인의 개인정보나 연락처 SNS 등을 기재시\n  계정 영구정지 등 불이익을 받을 수 있습니다.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
