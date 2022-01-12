import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
import 'package:byule/util/style/btStyle.dart';

import 'my_profile_pic_edit_page.dart';

class MyProfilePage extends StatefulWidget {
  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final MainController _controller = Get.find();

  UserModel get user => _controller.user.value;
  double _width = Get.width * 0.9;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SafeArea(
          bottom: false,
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: _width,
                              height: _width,
                              color: Colors.transparent,
                              child: Obx(
                                () => Swiper(
                                  itemBuilder: (BuildContext context, int index) {
                                    return cachedImage(
                                      user.pics[index],
                                      width: _width,
                                      height: _width,
                                      radius: 0,
                                    );
                                  },
                                  loop: false,
                                  itemCount: user.pics.length,
                                  pagination: new SwiperPagination(
                                    builder: new DotSwiperPaginationBuilder(
                                        color: Colors.white30,
                                        activeColor: Colors.white70),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        _editProfileImageButton(context),
                        Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Container(height: 10, color: Colors.grey[100])),
                        _buildName(user),
                        _profileItem('나이', user.age, () => agePick()),
                        _profileItem('키', user.tall, () => tallPick()),
                        _profileItem('직업', user.career, () => careerPick()),
                        _profileItem('지역', user.loc1, () => locationPick()),
                        _profileItem('세부 지역', user.loc2, () => locationPick2()),
                        Container(
                            height: 10,
                            width: double.infinity,
                            color: Colors.grey[100]),
                        _profileItem('체형', user.bodyType, () => bodyTypePick()),
                        _profileItem('흡연', user.smoke, () => smokePick()),
                        _profileItem('음주', user.drink, () => drinkPick()),
                        _profileItem('종교', user.religion, () => religionPick()),
                        _profileItem('MBTI', user.mbti, () => mbtiPick()),
                        Obx(() => _profileItem(
                            '간단소개', user.introduce, () => introducePick())),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Column _profileItem(String title, String text, VoidCallback onTap) {
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
            padding: EdgeInsets.symmetric(
                horizontal: Get.width * 0.05,
                vertical: title == '간단소개' ? 20 : 0),
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
                  width: Get.width * 0.65,
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

  Row _buildName(UserModel user) {
    return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: Get.width * 0.05, top: 25, bottom: 25),
          child: Text(
            user.name,
            style: TextStyle(
              fontSize: 23,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _editProfileImageButton(BuildContext context) {
    return TextButton(
      child: Text('프로필 사진 수정'),
      style: BtStyle.textSub200,
      onPressed: () => Get.to(() => MyProfileImageEditPage(), transition: Transition.rightToLeftWithFade),
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
  String _religion;
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
      selectedNumber: int.parse(user.age),
      maxLongSide: 400,
      onChanged: (value) => setState(() => _age = value),
      onConfirmed: () => _controller.changeProfileValue('age', _age),
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
      selectedNumber: int.parse(user.tall),
      maxLongSide: 400,
      onChanged: (value) => setState(() => _tall = value),
      onConfirmed: () => _controller.changeProfileValue('tall', _tall),
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
      selectedItem: user.career,
      onChanged: (value) => setState(() => _career = value),
      onConfirmed: () => _controller.changeProfileValue('career', _career),
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
      selectedItem: user.loc1,
      onChanged: (value) => setState(() => _location = value),
      onConfirmed: () {
        //지역 바꾸면 세부 지역 초기화
        _controller.changeProfileValue('loc2', '전체');

        //인창 지역1 바꾸면 지역2 설정
        _controller.changeProfileValue('loc1', _location,
            callback: () => locationPick2());
      },
    );
  }

  void locationPick2() {
    var selected = "";
    List<String> cityList;

    switch (user.loc1) {
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
      onConfirmed: () => _controller.changeProfileValue('loc2', _location2),
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

    return showMaterialScrollPicker(
      headerColor: AppColor.sub200,
      headerTextColor: Colors.white,
      maxLongSide: 400,
      confirmText: "확인",
      cancelText: "취소",
      context: context,
      title: "체형",
      items: bodyTypeList,
      selectedItem: user.bodyType,
      onChanged: (value) => setState(() => _bodyType = value),
      onConfirmed: () => _controller.changeProfileValue('bodyType', _bodyType,
          callback: user.smoke == null ? () => smokePick() : null),
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
      selectedItem: user.smoke,
      onChanged: (value) => setState(() => _smoke = value),
      onConfirmed: () => _controller.changeProfileValue('smoke', _smoke,
          callback: user.drink == null ? () => drinkPick() : null),
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
      selectedItem: user.drink,
      onChanged: (value) => setState(() => _drink = value),
      onConfirmed: () => _controller.changeProfileValue('drink', _drink,
          callback: user.religion == null ? () => religionPick() : null),
    );
  }

  void religionPick() {
    List<String> religionList = <String>[
      '무교',
      '기독교',
      '불교',
      '천주교',
      '기타',
    ];

    return showMaterialScrollPicker(
      headerColor: AppColor.sub200,
      headerTextColor: Colors.white,
      maxLongSide: 400,
      confirmText: "확인",
      cancelText: "취소",
      context: context,
      title: "종교",
      items: religionList,
      selectedItem: user.religion,
      onChanged: (value) => setState(() => _religion = value),
      onConfirmed: () => _controller.changeProfileValue('religion', _religion,
          callback: user.mbti == null ? () => mbtiPick() : null),
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
      selectedItem: user.mbti,
      onChanged: (value) => setState(() => _mbti = value),
      onConfirmed: () => _controller.changeProfileValue('mbti', _mbti),
    );
  }

  void introducePick() {
    Get.to(() => MyProfileIntroduceEditPage(), transition: Transition.fadeIn);
  }
}
