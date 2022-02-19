import 'dart:io';

import 'package:byule/model/memberModel.dart';
import 'package:byule/ui/widget/dialog/confirm_dialog.dart';
import 'package:byule/ui/widget/dialog/notification_dialog.dart';
import 'package:byule/util/style/btStyle.dart';
import 'package:byule/util/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/helpers/show_number_picker.dart';
import 'package:flutter_material_pickers/helpers/show_scroll_picker.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get/get.dart';
import 'package:byule/controller/main_controller.dart';
import 'package:byule/model/userModel.dart';
import 'package:byule/ui/drawer/my_profile_Intoduce_edit_page.dart';
import 'package:byule/ui/widget/cached_image.dart';
import 'package:byule/util/city_list_Info.dart';
import 'package:byule/util/style/appColor.dart';

class MemberEditPage extends StatefulWidget {
  final MemberModel member;
  final bool isEdit; // true => 수정, false => 추가

  MemberEditPage(this.member, this.isEdit);

  @override
  State<MemberEditPage> createState() => _MemberEditPageState();
}

class _MemberEditPageState extends State<MemberEditPage> {
  MainController _mainController = Get.find();

  UserModel get _user => _mainController.user.value;

  double _width = Get.width * 0.9;

  MemberModel _newMember = MemberModel();
  File imageFile;

  @override
  void initState() {
    setState(() {
      _newMember = widget.member;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.5],
              colors: [Colors.white, Colors.grey[100]])
      ),
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: ScrollConfiguration(
                  behavior: ScrollBehavior(),
                  child: GlowingOverscrollIndicator(
                    axisDirection: AxisDirection.down,
                    color: Colors.white,
                    child: Stack(
                      children: [
                        Container(color: Colors.white),
                        SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        width: _width,
                                        height: _width,
                                        color: Colors.grey[200],
                                        child: imageFile == null ? GestureDetector(
                                          onTap: () async {
                                            imageFile = await Util.getImage();
                                            if (imageFile != null) {
                                              setState(() {});
                                              _newMember.url = imageFile.path;
                                            }
                                          },
                                          child: cachedImage(
                                            _newMember.url??'',
                                          ),
                                        ) : Image(
                                            image: FileImage(imageFile),
                                            fit: BoxFit.cover
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      child: InkWell(
                                        onTap: () => Get.back(),
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          child: Icon(
                                            Icons.arrow_back_ios,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      top: 10,
                                      left: 10,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(padding: const EdgeInsets.only(top: 10.0), child: Container(height: 10, color: Colors.grey[100])),
                              _profileItem('나이', _newMember.age, () => agePick(), mustNeed: true),
                              _profileItem('키', _newMember.tall, () => tallPick(), mustNeed: true),
                              _profileItem('직업', _newMember.career, () => careerPick(), mustNeed: true),
                              _profileItem('지역', _newMember.loc1, () => locationPick(), mustNeed: true),
                              _profileItem('세부 지역', _newMember.loc2, () => locationPick2(), mustNeed: true),
                              Container(height: 10, width: double.infinity, color: Colors.grey[100]),
                              _profileItem('체형', _newMember.bodyType, () => bodyTypePick()),
                              _profileItem('흡연', _newMember.smoke, () => smokePick()),
                              _profileItem('음주', _newMember.drink, () => drinkPick()),
                              _profileItem('MBTI', _newMember.mbti, () => mbtiPick()),
                              // _profileItem('간단소개', _newMember.introduce, () => introducePick()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.grey[100],
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: Get.width*0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: widget.isEdit ? Get.width*0.7 : Get.width*0.9,
                        child: TextButton(onPressed: _newMember.age != null &&
                            _newMember.tall != null && _newMember.career != null &&
                            _newMember.loc1 != null && _newMember.loc2 != null
                            ? () {
                              widget.isEdit
                                  ? _mainController.editMember(_newMember)
                                  : _mainController.addMember(_newMember);
                              Get.back();
                            } : null,
                            style: BtStyle.textSub200,
                            child: Text(widget.isEdit ? "수정하기" : "등록하기")),
                      ),
                      if(widget.isEdit)
                        Container(
                          width: Get.width*0.15,
                          child: TextButton(onPressed: () {
                            Get.dialog(NotificationDialog(
                              title: "멤버 삭제",
                              contents: "정말 삭제하시겠습니까?",
                              buttonText: '삭제',
                              onPressed: () => _mainController.deleteMember(_newMember),
                            ));
                          },
                              style: BtStyle.textMain100,
                              child: Icon(Icons.cancel_outlined, size: Get.width*0.08,)),
                        )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column _profileItem(String title, String text, VoidCallback onTap, {bool mustNeed = false}) {
    return Column(
      children: <Widget>[
        if (title != '체형')
          Container(
            height: 0.3,
            color: Colors.grey[200],
          ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: Get.width * 0.05, vertical: title == '간단소개' ? 20 : 0),
            constraints: BoxConstraints(minHeight: 55),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: Get.width * 0.25,
                  color: Colors.transparent,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black45,
                    ),
                  ),
                ),
                Container(
                  color: Colors.transparent,
                  width: Get.width * 0.55,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: text != null
                        ? <Widget>[
                            Text(
                              text,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ]
                        : <Widget>[
                            Text(
                              '입력해주세요',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                  ),
                ),
                mustNeed ? Container(
                  width: Get.width * 0.1,
                  height: 50,
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.check_circle_outline,
                    color: text != null ? AppColor.sub300 : Colors.grey[400],
                    // color: AppColor.sub300,
                  ),
                ) : Container(width: Get.width * 0.1,)
              ],
            ),
          ),
        ),
        if (title == '간단소개')
          Container(
            height: 50,
            color: Colors.grey[100],
          ),
      ],
    );
  }

  int _age;
  int _tall;
  String _career;
  String _location;
  String _location2;

  String _bodyType;
  String _smoke;
  String _drink;
  String _mbti;

  void agePick() {
    return showMaterialNumberPicker(
      headerColor: AppColor.sub200,
      headerTextColor: Colors.white,
      context: context,
      title: '나이',
      maxNumber: 40,
      minNumber: 19,
      confirmText: "확인",
      cancelText: "취소",
      selectedNumber: int.parse(_newMember.age ?? _user.age),
      maxLongSide: 400,
      onChanged: (value) => setState(() => _age = value),
      onConfirmed: () {
        setState(() => _newMember.age = _age.toString());
        if (_newMember.tall == null) tallPick();
      },
    );
  }

  void tallPick() {
    return showMaterialNumberPicker(
      headerColor: AppColor.sub200,
      headerTextColor: Colors.white,
      context: context,
      title: '키',
      maxNumber: 210,
      minNumber: 130,
      confirmText: "확인",
      cancelText: "취소",
      selectedNumber: int.parse(_newMember.tall ?? _user.tall),
      maxLongSide: 400,
      onChanged: (value) => setState(() => _tall = value),
      onConfirmed: () {
        setState(() => _newMember.tall = _tall.toString());
        if (_newMember.career == null) careerPick();
      },
    );
  }

  void careerPick() {
    List<String> careerList = <String>[
      '회사원',
      '학생',
      '아르바이트',
      '취업준비생',
      '전문직',
      '공무원',
      '자영업',
      '금융직',
      '의료직',
      '기타',
    ];

    return showMaterialScrollPicker(
      headerColor: AppColor.sub200,
      headerTextColor: Colors.white,
      maxLongSide: 400,
      confirmText: "확인",
      cancelText: "취소",
      context: context,
      title: "직업",
      items: careerList,
      selectedItem: _newMember.career,
      onChanged: (value) => setState(() => _career = value),
      onConfirmed: () {
        setState(() => _newMember.career = _career.toString());
        if (_newMember.loc1 == null) locationPick();
      },
    );
  }

  void locationPick() {
    List<String> location1List = <String>[
      '서울',
      '경기',
      '인천',
      '세종',
      '부산',
      '경남',
      '경북',
      '울산',
      '대전',
      '충남',
      '충북',
      '대구',
      '강원',
      '전남',
      '전북',
      '광주',
      '제주',
    ];

    return showMaterialScrollPicker(
      headerColor: AppColor.sub200,
      headerTextColor: Colors.white,
      maxLongSide: 400,
      confirmText: "확인",
      cancelText: "취소",
      context: context,
      title: "지역",
      items: location1List,
      selectedItem: _newMember.loc1,
      onChanged: (value) => setState(() => _location = value),
      onConfirmed: () {
        //지역 바꾸면 세부 지역 초기화
        setState(() {
          _newMember.loc2 = '전체';
          _newMember.loc1 = _location;
        });

        locationPick2();
      },
    );
  }

  void locationPick2() {
    var selected = "";
    List<String> cityList;

    switch (_newMember.loc1) {
      case '지역':
        {
          cityList = CityListInfo().options0;
        }
        break;

      case '서울':
        {
          cityList = CityListInfo().options1;
        }
        break;

      case '부산':
        {
          cityList = CityListInfo().options2;
        }
        break;

      case '대구':
        {
          cityList = CityListInfo().options3;
        }
        break;

      case '인천':
        {
          cityList = CityListInfo().options4;
        }
        break;

      case '광주':
        {
          cityList = CityListInfo().options5;
        }
        break;

      case '대전':
        {
          cityList = CityListInfo().options6;
        }
        break;

      case '울산':
        {
          cityList = CityListInfo().options7;
        }
        break;

      case '경기':
        {
          cityList = CityListInfo().options8;
        }
        break;

      case '강원':
        {
          cityList = CityListInfo().options9;
        }
        break;

      case '충북':
        {
          cityList = CityListInfo().options10;
        }
        break;

      case '충남':
        {
          cityList = CityListInfo().options11;
        }
        break;

      case '세종':
        {
          cityList = CityListInfo().options12;
        }
        break;

      case '전북':
        {
          cityList = CityListInfo().options13;
        }
        break;

      case '전남':
        {
          cityList = CityListInfo().options14;
        }
        break;

      case '경상북도':
        {
          cityList = CityListInfo().options15;
        }
        break;

      case '경남':
        {
          cityList = CityListInfo().options16;
        }
        break;

      case '제주':
        {
          cityList = CityListInfo().options17;
        }
        break;

      default:
        {
          cityList = CityListInfo().options0;
        }
        break;
    }

    return showMaterialScrollPicker(
      headerColor: AppColor.sub200,
      headerTextColor: Colors.white,
      maxLongSide: 400,
      confirmText: "확인",
      cancelText: "취소",
      context: context,
      title: "지역",
      items: cityList,
      selectedItem: selected,
      onChanged: (value) => setState(() => _location2 = value),
      onConfirmed: () {
        setState(() => _newMember.loc2 = _location2);
        if (_newMember.bodyType == null) bodyTypePick();
      },
    );
  }

  void bodyTypePick() {
    List<String> bodyTypeList = <String>[
      '마른',
      '슬림탄탄한',
      '보통',
      '통통한',
      '근육있는',
      '볼륨있는',
      '글래머한',
    ];

    List<String> manBodyTypeList = <String>[
      '마른',
      '슬림탄탄한',
      '보통',
      '통통한',
      '근육있는',
      '볼륨있는',
    ];

    return showMaterialScrollPicker(
      headerColor: AppColor.sub200,
      headerTextColor: Colors.white,
      maxLongSide: 400,
      confirmText: "확인",
      cancelText: "취소",
      context: context,
      title: "체형",
      items: _user.man ? manBodyTypeList : bodyTypeList,
      selectedItem: _newMember.bodyType,
      onChanged: (value) => setState(() => _bodyType = value),
      onConfirmed: () {
        setState(() => _newMember.bodyType = _bodyType);
        if (_newMember.smoke == null) smokePick();
      },
    );
  }

  void smokePick() {
    List<String> smokeList = <String>[
      '비흡연',
      '흡연',
    ];

    return showMaterialScrollPicker(
      headerColor: AppColor.sub200,
      headerTextColor: Colors.white,
      maxLongSide: 400,
      confirmText: "확인",
      cancelText: "취소",
      context: context,
      title: "흡연",
      items: smokeList,
      selectedItem: _newMember.smoke,
      onChanged: (value) => setState(() => _smoke = value),
      onConfirmed: () {
        setState(() => _newMember.smoke = _smoke);
        if (_newMember.drink == null) drinkPick();
      },
    );
  }

  void drinkPick() {
    List<String> drinkList = <String>[
      '전혀안함',
      '가끔',
      '자주',
    ];

    return showMaterialScrollPicker(
      headerColor: AppColor.sub200,
      headerTextColor: Colors.white,
      maxLongSide: 400,
      confirmText: "확인",
      cancelText: "취소",
      context: context,
      title: "음주",
      items: drinkList,
      selectedItem: _newMember.drink,
      onChanged: (value) => setState(() => _drink = value),
      onConfirmed: () {
        setState(() => _newMember.drink = _drink);
        if (_newMember.mbti == null) mbtiPick();
      },
    );
  }

  void mbtiPick() {
    List<String> mbtiList = <String>[
      'ISTJ',
      'ISTP',
      'ISFP',
      'ISFJ',
      'ESTJ',
      'ESTP',
      'ESFP',
      'ESFJ',
      'INTJ',
      'INTP',
      'INFP',
      'INFJ',
      'ENTJ',
      'ENTP',
      'ENFP',
      'ENFJ',
    ];

    return showMaterialScrollPicker(
      headerColor: AppColor.sub200,
      headerTextColor: Colors.white,
      maxLongSide: 400,
      confirmText: "확인",
      cancelText: "취소",
      context: context,
      title: "MBTI",
      items: mbtiList,
      selectedItem: _newMember.mbti,
      onChanged: (value) => setState(() => _mbti = value),
      onConfirmed: () {
        setState(() => _newMember.mbti = _mbti);
      },
    );
  }

  //TODO 수정 필요
  void introducePick() {
    Get.to(() => MyProfileIntroduceEditPage(), transition: Transition.fadeIn);
  }
}
