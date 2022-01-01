import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signalmeeting/controller/main_controller.dart';
import 'package:signalmeeting/model/userModel.dart';
import 'package:signalmeeting/services/database.dart';
import 'package:signalmeeting/ui/drawer/personalInfo.dart';
import 'package:signalmeeting/ui/drawer/terms.dart';
import 'package:signalmeeting/ui/lobby.dart';
import 'package:signalmeeting/ui/start/start_page_3.dart';
import 'package:signalmeeting/ui/widget/flush_bar.dart';
import 'package:signalmeeting/util/style/appColor.dart';
import 'package:signalmeeting/util/style/btStyle.dart';
import 'package:signalmeeting/util/uiData.dart';

class StartPage2 extends StatefulWidget {
  @override
  _StartPage2State createState() => _StartPage2State();
}

class _StartPage2State extends State<StartPage2> {
  MainController _controller = Get.find();
  UserModel get user => _controller.user.value;
  FirebaseAuth _auth = FirebaseAuth.instance;

  final GlobalKey<FormState> _phoneNumKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumController = TextEditingController();
  final GlobalKey<FormState> _authNumKey = GlobalKey<FormState>();
  final TextEditingController _authNumController = TextEditingController();

  String _verificationId;

  bool messageSent = false;

  bool verifySmsResult;

  bool isChecked = false;
  bool validation = false;

  // 포커스노트 선언
  FocusNode myFocusNode;

  smsAuth() async {
    print(UiData().serverPhone(_phoneNumController.text),);
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: UiData().serverPhone(_phoneNumController.text),
          timeout: const Duration(seconds: 5),
          verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
            await _auth.signInWithCredential(phoneAuthCredential);
            CustomedFlushBar(context, "Phone number automatically verified and user signed in: ${FirebaseAuth.instance.currentUser.uid}");
          },
          verificationFailed: (FirebaseAuthException authException) {
            CustomedFlushBar(context, 'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
          },
          codeSent: (String verificationId, [int forceResendingToken]) async {
            CustomedFlushBar(context, 'Please check your phone for the verification code.');
            _verificationId = verificationId;
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            CustomedFlushBar(context, "verification code: " + verificationId);
            _verificationId = verificationId;
          });
    } catch (e) {
      print("Failed to Verify Phone Number: $e");
    }
  }

  Future<bool> signInWithPhoneNumber() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _authNumController.text,
      );
      final User user = (await _auth.signInWithCredential(credential)).user;
      if (user != null)
        return Future.value(true);
      else
        return Future.value(false);
    } catch (e) {
      CustomedFlushBar(context, "Failed to sign in: " + e.toString());
      return Future.value(false);
    }
  }

  @override
  void initState() {

    super.initState();
    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15.0, top: 50),
              child: Text(
                '본인 인증',
                style: TextStyle(color: AppColor.sub, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          PhoneNum(context),
          messageSent ? AuthNum(context) : Container(),
          messageSent ? checkTerm(context) : Container(),
        ],
      ),
    );
  }

  Widget PhoneNum(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Form(
        key: _phoneNumKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Flexible(
              child: TextFormField(
                onChanged: (text) => _controller.updateUser(user..phone = text),
                controller: _phoneNumController,
                //텍스트 수 11자 제한(전화번호 텍스트 수)
                maxLength: 11,
                //숫자 키보드 띄
                keyboardType: TextInputType.number,
                //내부 디자인
                decoration: InputDecoration(
                  //lengthCount 지워줌
                  counterText: "",
                  //왼쪽으로부터 10만큼 띄워서 시작
                  contentPadding: new EdgeInsets.fromLTRB(10, 0, 0, 0),
                  fillColor: Colors.white,
                  filled: true,
                  //focus 됐을 시
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColor.sub100, width: 1),
                  ),
                  //focus 되기 전
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColor.hint, width: 0.15),
                  ),
                  //validator 실행 후
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: AppColor.hint),
                  labelText: '전화번호',
                ),
                cursorColor: AppColor.sub100,
                //자동 focus
                autofocus: true,
                validator: (value) {
                  if (_phoneNumController.text.length < 11) {
                    return '전화번호 입력';
                  } else {
                    return null;
                  }
                },
              ),
            ),
            Container(
              width: 10,
            ),
            TextButton(
              child: Center(
                child: Text(
                  '전송',
                ),
              ),
              style: BtStyle.start,
              onPressed: () async {
                if (_phoneNumKey.currentState.validate()) {
                  await smsAuth();
                  messageSent = true;
                  setState(() {});
                  FocusScope.of(context).requestFocus(myFocusNode);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget AuthNum(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Form(
        key: _authNumKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Flexible(
              child: TextFormField(
                focusNode: myFocusNode,
                onChanged: (text) {
                  _controller.updateUser(user..authCode = text);
                  if(text.length == 6 && isChecked){
                    setState(() {
                      validation = true;
                    });
                  } else {
                    setState(() {
                      validation = false;
                    });
                  }
                },
                controller: _authNumController,
                //텍스트 수 4자 제한(인증번호 텍스트 수)
                maxLength: 6,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  //lengthCount 지워줌
                  counterText: "",
                  contentPadding: new EdgeInsets.fromLTRB(10, 0, 0, 0),
                  fillColor: Colors.white,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue[100], width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 0.15),
                  ),
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.grey),
                  labelText: '인증번호',
                ),
                cursorColor: Colors.blue[100],
                autofocus: true,
                //인증번호랑 일치하는지 확인
                validator: (value) {
                  if (verifySmsResult == false) {
                    return '인증 실패';
                  }
                  return null;
                },
              ),
            ),
            Container(
              width: 10,
            ),
            ButtonTheme(
              height: 47,
              child: TextButton(
                child: Text(
                  '인증',
                ),
                style: BtStyle.start,
                onPressed: (!validation) ? null : () async {
                  bool result = await signInWithPhoneNumber();
                  //validator 에 future 값 넣기 위한 꼼수
                  setState(() {
                    if (result) {
                      verifySmsResult = true;
                    } else {
                      verifySmsResult = false;
                    }
                  });

                  if (_authNumKey.currentState.validate()) {
                    bool result = await DatabaseService.instance.checkAuth(_auth.currentUser.uid, _auth.currentUser.phoneNumber);
                    //이미 계정 있으면 로그인
                    if (result)
                      Get.offAll(() => LobbyPage());
                    //회원가입 페이지
                    else
                      Get.to(() => StartPage3());
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget checkTerm(context){
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Row(
        children: <Widget>[
          Checkbox(
            activeColor: Colors.blue,
              shape: RoundedRectangleBorder( // Making around shape
                  borderRadius: BorderRadius.circular(4)),
              value: isChecked,
              onChanged: (value) {
                setState(() {
                  isChecked = value;
                });
                if(isChecked && _authNumController.text.length == 6){
                  validation = true;
                } else {
                  validation = false;
                }
              }),
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.to(() => Terms(), transition: Transition.rightToLeftWithFade),
                  child: Text("이용 약관", style: TextStyle(fontWeight: FontWeight.bold,decoration: TextDecoration.underline, height: 1),)),
              Text(" 및 ", style: TextStyle(height: 1),),
              GestureDetector(
                  onTap: () => Get.to(() => PersonalInfo(), transition: Transition.rightToLeftWithFade),
                  child: Text("개인정보 처리방침", style: TextStyle(fontWeight: FontWeight.bold,decoration: TextDecoration.underline, height: 1),)),
              Text("을 확인했습니다", style: TextStyle(height: 1),),
            ],
          ),
        ],
      ),
    );
  }

}
