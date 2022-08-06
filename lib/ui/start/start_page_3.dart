import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:get/get.dart';
import 'package:byule/controller/main_controller.dart';
import 'package:byule/model/userModel.dart';
import 'package:byule/ui/start/start_page_4.dart';
import 'package:byule/ui/widget/flush_bar.dart';
import 'package:byule/util/city_list_Info.dart';
import 'package:byule/util/style/appColor.dart';
import 'package:byule/util/style/btStyle.dart';

class StartPage3 extends StatefulWidget {
  @override
  _StartPage3State createState() => _StartPage3State();
}

class _StartPage3State extends State<StartPage3> {

  MainController _controller = Get.find();
  UserModel get user => _controller.user.value;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nicknameController = TextEditingController();

  //입력된 상태인지 확인 위함
  bool confirmNickname = false;
  bool confirmGender = false;
  bool confirmAge = false;
  bool confirmtall = false;
  bool confirmResidence = false;
  bool confirmResidence2 = false;
  bool confirmCareer = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15.0, top: 50),
                child: Text(
                  '계정 정보',
                  style: TextStyle(
                      color: AppColor.sub,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            //낙네임만 텍스트폼 입력 받음
            //나머지는 onTap 통해 alertdialog 느낌으로(연속적으로 넘어가게)
            Nickname(context),
            ProfilForm(gender, confirmGender, GenderPick),
            ProfilForm(age, confirmAge, AgePick),
            ProfilForm(tall, confirmtall, tallPick),
            ProfilForm(residence, confirmResidence, ResidencePick),
            ProfilForm(residence2, confirmResidence2, ResidencePick2),
            ProfilForm(career, confirmCareer, CareerPick),
            //다 입력 받았을 시 넘어가도록(순서대로 입력 안가는 경우를 위해)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16.0),
              child: TextButton(
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
                style: BtStyle.start,
                onPressed: (confirmNickname &&
                    confirmGender &&
                    confirmAge &&
                    confirmtall &&
                    confirmResidence &&
                    confirmResidence2 &&
                    confirmCareer)
                    ? () => Get.to(StartPage4())
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String gender = '성별';
  String age = '나이';
  String tall = '키';
  String residence = '지역';
  String residence2 = '세부 지역';
  String career = '직업';

  //validator 넣어야 됨
  Widget Nickname(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: TextFormField(
                onChanged: (text) => _controller.updateUser(user..profileInfo['name'] = text),
                //텍스트 수 10자 제한
                maxLength: 20,
                controller: _nicknameController,
                decoration: InputDecoration(
                  //counterText 지워줌
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
                  labelText: '닉네임',
                ),
                cursorColor: Colors.blue[100],
                autofocus: true,
                validator: (value) {
                  if (value.isEmpty) {
                    return '닉네임 입력';
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
              child: Text(
                '입력',
              ),
              style: BtStyle.start,
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  confirmNickname = true;
                  CustomedFlushBar(context, "닉네임 입력이 완료되었습니다");
                }
                //키보드 창 내리고 SnackBar 띄움
                FocusScope.of(context).unfocus();
              },
            )
          ],
        ),
      ),
    );
  }

  //닉네임 제외 Form
  Widget ProfilForm(String labelText, bool confirmed, Function Picker) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: <Widget>[
          new Flexible(
            child: CupertinoTextField(
              onTap: () {
                //TextField 를 disable 하고 GestureDetector 쓰려는데 안먹혀서 다음과 같이 함
                //TextField 에서 focus 삭제
                FocusScope.of(context).requestFocus(new FocusNode());
                Picker();
              },
              padding: const EdgeInsets.all(12),
              placeholder: labelText,
              placeholderStyle:
              TextStyle(color: confirmed ? Colors.black : Colors.grey),
            ),
          ),
          Container(
            width: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Icon(Icons.check_circle_outline,
                size: 32,
                color: confirmed ? AppColor.sub200 : Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  //닉네임 입력 후 실행될 Picker 들
  var selectedGender = "남자";
  void GenderPick() {

    List<String> genderList = <String>['남자', '여자'];

    return showMaterialScrollPicker(
      headerColor: AppColor.main100,
      headerTextColor: Colors.white,
      maxLongSide: 400,
      confirmText: "확인",
      cancelText: "취소",
      context: context,
      title: "성별",
      items: genderList,
      selectedItem: selectedGender,
      onChanged: (value) => setState(() => gender = value),
      onConfirmed: () {
        selectedGender = gender;
        _controller.updateUser(user..profileInfo['man'] = gender == '남자');
        confirmGender = true;
        AgePick();
      },
    );
  }

  var selectedAge = 20;
  void AgePick() {
    return showMaterialNumberPicker(
      headerColor: AppColor.main100,
      headerTextColor: Colors.white,
      context: context,
      title: '나이',
      maxNumber: 40,
      minNumber: 20,
      confirmText: "확인",
      cancelText: "취소",
      selectedNumber: selectedAge,
      maxLongSide: 400,
      onChanged: (value) => setState(() => age = value.toString()),
      onConfirmed: () {
        selectedAge = int.parse(age);
        _controller.updateUser(user..profileInfo['age'] = age);
        confirmAge = true;
        tallPick();
      },
    );
  }

  var selectedTall = 140;
  void tallPick() {
    return showMaterialNumberPicker(
      headerColor: AppColor.main100,
      headerTextColor: Colors.white,
      context: context,
      title: '키',
      maxNumber: 200,
      minNumber: 140,
      confirmText: "확인",
      cancelText: "취소",
      selectedNumber: selectedTall,
      maxLongSide: 400,
      onChanged: (value) => setState(() => tall = value.toString()),
      onConfirmed: () {
        selectedAge = int.parse(tall);
        _controller.updateUser(user..profileInfo['tall'] = int.parse(tall));
        confirmtall = true;
        ResidencePick();
      },
    );
  }


  var selectedResidence = "서울";
  void ResidencePick() {

    List<String> genderList = <String>[
      '서울', '부산', '대구', '인천', '광주', '대전', '울산', '경기', '강원',
      '충북', '충남', '세종', '전북', '전남', '경북', '경남', '제주',
    ];

    return showMaterialScrollPicker(
      headerColor: AppColor.main100,
      headerTextColor: Colors.white,
      maxLongSide: 400,
      confirmText: "확인",
      cancelText: "취소",
      context: context,
      title: "지역",
      items: genderList,
      selectedItem: selectedResidence,
      onChanged: (value) => setState(() => residence = value),
      onConfirmed: () {
        selectedResidence = residence;
        _controller.updateUser(user..profileInfo['loc1'] = residence);
        confirmResidence = true;

        //지역 - 세부지역 안맞아 지는 경우 대비해서 '세부 지역' 초기화
        confirmResidence2 = false;
        residence2 = '세부 지역';

        ResidencePick2();
      },
    );
  }


  void ResidencePick2() {
    var selected = "";
    List<String> cityList;

    switch (residence) {
      case '지역':{cityList = CityListInfo().options0;} break;
      case '서울':{cityList = CityListInfo().options1;} break;
      case '부산':{cityList = CityListInfo().options2;} break;
      case '대구':{cityList = CityListInfo().options3;} break;
      case '인천':{cityList = CityListInfo().options4;} break;
      case '광주':{cityList = CityListInfo().options5;} break;
      case '대전':{cityList = CityListInfo().options6;} break;
      case '울산':{cityList = CityListInfo().options7;} break;
      case '경기':{cityList = CityListInfo().options8;} break;
      case '강원':{cityList = CityListInfo().options9;} break;
      case '충북':{cityList = CityListInfo().options10;} break;
      case '충남':{cityList = CityListInfo().options11;} break;
      case '세종':{cityList = CityListInfo().options12;} break;
      case '전북':{cityList = CityListInfo().options13;} break;
      case '전남':{cityList = CityListInfo().options14;} break;
      case '경북':{cityList = CityListInfo().options15;} break;
      case '경남':{cityList = CityListInfo().options16;} break;
      case '제주':{cityList = CityListInfo().options17;} break;
      default:{cityList = CityListInfo().options0;} break;
    }

    return showMaterialScrollPicker(
      headerColor: AppColor.main100,
      headerTextColor: Colors.white,
      maxLongSide: 400,
      confirmText: "확인",
      cancelText: "취소",
      context: context,
      title: "지역",
      items: cityList,
      selectedItem: cityList[0],
      onChanged: (value) => setState(() => residence2 = value),
      onConfirmed: () {
        _controller.updateUser(user..profileInfo['loc2'] = residence2);
        confirmResidence2 = true;
        CareerPick();
      },
    );
  }

  var selectedCareer = "회사원";
  void CareerPick() {

    List<String> genderList = <String>[
      '회사원', '학생', '아르바이트', '취업준비생', '전문직', '공무원', '자영업', '금융직',
      '의료직', '기타',];

    return showMaterialScrollPicker(
      headerColor: AppColor.main100,
      headerTextColor: Colors.white,
      maxLongSide: 400,
      confirmText: "확인",
      cancelText: "취소",
      context: context,
      title: "직업",
      items: genderList,
      selectedItem: selectedCareer,
      onChanged: (value) => setState(() => career = value),
      onConfirmed: () async {
        selectedCareer = career;
        _controller.updateUser(user..profileInfo['career'] = career);
        confirmCareer = true;
        if (confirmNickname &&
            confirmGender &&
            confirmAge &&
            confirmtall &&
            confirmResidence &&
            confirmResidence2 &&
            confirmCareer) {
          Get.to(() => StartPage4());
        }
      },
    );
  }
}