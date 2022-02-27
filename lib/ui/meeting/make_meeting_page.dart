import 'dart:io';

import 'package:byule/ui/widget/member/member_pick_list.dart';
import 'package:byule/util/style/appColor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:byule/controller/main_controller.dart';
import 'package:byule/model/userModel.dart';
import 'package:byule/services/database.dart';
import 'package:byule/ui/widget/dialog/city_list_dialog.dart';
import 'package:byule/ui/widget/flush_bar.dart';
import 'package:byule/util/style/btStyle.dart';
import 'package:byule/util/util.dart';
import 'package:smart_select/smart_select.dart';

class MakeMeetingPage extends StatefulWidget {
  @override
  _MakeMeetingPageState createState() => _MakeMeetingPageState();
}

class _MakeMeetingPageState extends State<MakeMeetingPage> {
  MainController _mainController = Get.find();
  UserModel get user => _mainController.user.value;

  final GlobalKey<FormState> _formKeyTitle = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();

  final GlobalKey<FormState> _formKeyLocation = GlobalKey<FormState>();
  final TextEditingController _locationController = TextEditingController();

  final GlobalKey<FormState> _formKeyIntroduce = GlobalKey<FormState>();
  final TextEditingController _introduceController = TextEditingController();

  RxList<int> pickedMemberIndexList = <int>[].obs;
  RxInt needMemberNum = 0.obs;

  bool confirmTitle = false;
  bool confirmLocation = false;
  bool confirmIntroduce = false;


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 1],
              colors: [AppColor.main100, Colors.white])
      ),
      child: SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColor.main100,
            elevation: 0,
            leading: IconButton(
              highlightColor: Colors.white,
              icon: Icon(Icons.arrow_back_ios, color: Colors.white,),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            centerTitle: true,
            title: Text(
              '미팅 등록',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: [0.0, 0.90], colors: [AppColor.main100, Colors.white])),
              ),
              Column(
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ScrollConfiguration(
                      behavior: ScrollBehavior(),
                      child: GlowingOverscrollIndicator(
                        axisDirection: AxisDirection.down,
                        color: Colors.white,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: Get.width*0.05, vertical: 10),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if(FocusScope.of(context).hasFocus){
                                      FocusScope.of(context).unfocus();
                                    }
                                  },
                                  child: Card(
                                    margin: EdgeInsets.all(0),
                                    elevation: 10,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
//                              color: Colors.white,
                                      ),
                                      padding: EdgeInsets.fromLTRB(30, 15, 30, 10),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          //기본정보
                                          Padding(
                                            padding: const EdgeInsets.only(top: 15.0),
                                            child: Text(
                                              '기본 정보',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontFamily: "AppleSDGothicNeoB",
                                              ),
                                            ),
                                          ),
                                          //제목
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 8.0, top: 8),
                                            child: Form(
                                              key: _formKeyTitle,
                                              //바뀔때 마다 validator 실행해서 비었는지 확인
                                              onChanged: () {
                                                setState(() {
                                                  if (_formKeyTitle.currentState.validate()) {
                                                    confirmTitle = true;
                                                  } else {
                                                    confirmTitle = false;
                                                  }
                                                });
                                              },
                                              child: Row(
                                                //validator 실행시, 아이콘과 같은 높이 유지
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Flexible(
                                                    child: TextFormField(
                                                      controller: _titleController,
                                                      //몇글자로 할지 추후 조정(기타 텍스트 들에 대해서도)
                                                      //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                                                      //최대 글자 수 조정
                                                      maxLength: 30,
                                                      cursorColor: Colors.red[100],
                                                      decoration: InputDecoration(
                                                        //Icon이 오른쪽에 디폴트 패딩이 있어서 Row로 조정
                                                        suffixIcon: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: <Widget>[
                                                            Icon(
                                                              Icons.check_circle_outline,
                                                              color: confirmTitle ? AppColor.main200 : Colors.grey[400],
                                                            ),
                                                          ],
                                                        ),
                                                        //사용가능일 때, border 색 지정(안해주면 theme color로 지정)
                                                        focusedBorder: UnderlineInputBorder(
                                                          borderSide: BorderSide(color: Colors.grey[500]),
                                                        ),
                                                        //maxLength 표시 지워줌
                                                        counterText: "",
                                                        // 텍스트 입력시 지워지는 hint 사용 (not label)
                                                        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 15, fontFamily: "AppleSDGothicNeoM"),
                                                        hintText: '제목',
                                                      ),
                                                      style: TextStyle(fontFamily: "AppleSDGothicNeoM",),
                                                      validator: (value) {
                                                        if (value.isEmpty) {
                                                          return '제목을 입력해주세요';
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          //미팅 인원
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 8.0, top: 8),
                                            child: Row(
                                              //validator 실행시, 아이콘과 같은 높이 유지
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Number(),
                                              ],
                                            ),
                                          ),
                                          //위치
                                          Padding(
                                            padding: const EdgeInsets.only(top: 15.0),
                                            child: Text(
                                              '위치',
                                              style: TextStyle(
                                                fontFamily: "AppleSDGothicNeoB",
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          //시.도
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 8.0, top: 8),
                                            child: Row(
                                              //validator 실행시, 아이콘과 같은 높이 유지
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Cityt1(),
                                              ],
                                            ),
                                          ),
                                          //시.군.구
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 8.0, top: 8),
                                            child: Row(
                                              //validator 실행시, 아이콘과 같은 높이 유지
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                City2(city1),
                                              ],
                                            ),
                                          ),
                                          // //세부 위치
                                          // Padding(
                                          //   padding: const EdgeInsets.only(bottom: 8.0, top: 8),
                                          //   child: Form(
                                          //     key: _formKeyLocation,
                                          //     //바뀔때 마다 validator 실행해서 비었는지 확인
                                          //     onChanged: () {
                                          //       setState(() {
                                          //         if (_formKeyLocation.currentState.validate()) {
                                          //           confirmLocation = true;
                                          //         } else {
                                          //           confirmLocation = false;
                                          //         }
                                          //       });
                                          //     },
                                          //     child: city2 == "미정" ? Container() : Row(
                                          //       //validator 실행시, 아이콘과 같은 높이 유지
                                          //       crossAxisAlignment: CrossAxisAlignment.start,
                                          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          //       children: <Widget>[
                                          //         Flexible(
                                          //           child: TextFormField(
                                          //             controller: _locationController,
                                          //             //몇글자로 할지 추후 조정(기타 텍스트 들에 대해서도)
                                          //             //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                                          //             //최대 글자 수 조정
                                          //             maxLength: 30,
                                          //             cursorColor: Colors.red[100],
                                          //             decoration: InputDecoration(
                                          //               //Icon이 오른쪽에 디폴트 패딩이 있어서 Row로 조정
                                          //               suffixIcon: Row(
                                          //                 mainAxisSize: MainAxisSize.min,
                                          //                 mainAxisAlignment: MainAxisAlignment.end,
                                          //                 children: <Widget>[
                                          //                   /*
                                          //                   Icon(
                                          //                     Icons.check_circle_outline,
                                          //                     color: confirmLocation ? AppColor.main200 : Colors.grey[400],
                                          //                   ),
                                          //
                                          //                    */
                                          //                 ],
                                          //               ),
                                          //               //사용가능일 때, border 색 지정(안해주면 theme color로 지정)
                                          //               focusedBorder: UnderlineInputBorder(
                                          //                 borderSide: BorderSide(color: Colors.grey[500]),
                                          //               ),
                                          //               //maxLength 표시 지워줌
                                          //               counterText: "",
                                          //               // 텍스트 입력시 지워지는 hint 사용 (not label)
                                          //               hintStyle: TextStyle(color: Colors.grey[600], fontSize: 15, fontFamily: "AppleSDGothicNeoM"),
                                          //               hintText: '세부 위치',
                                          //             ),
                                          //             style: TextStyle(fontFamily: "AppleSDGothicNeoM",),
                                          //             /*
                                          //             validator: (value) {
                                          //               if (value.isEmpty) {
                                          //                 return '세부 위치를 입력해주세요';
                                          //               }
                                          //               return null;
                                          //             },
                                          //
                                          //              */
                                          //           ),
                                          //         ),
                                          //       ],
                                          //     ),
                                          //   ),
                                          // ),
                                          //소개
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 15.0),
                                                        child: Text(
                                                          '이미지',
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontFamily: "AppleSDGothicNeoB",
                                                          ),
                                                        ),
                                                      ),
                                                      photoBox(),
                                                    ],
                                                  ),
                                                  SizedBox(width: 15,),
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 15.0),
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                          children: [
                                                            Text(
                                                              '멤버',
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                fontFamily: "AppleSDGothicNeoB",
                                                              ),
                                                            ),
                                                            SizedBox(width:5),
                                                            Obx(() => Text(
                                                                  '(${pickedMemberIndexList.length}/$needMemberNum)',
                                                                  style: TextStyle(color: pickedMemberIndexList.length == needMemberNum.value && needMemberNum.value != 0 ?  AppColor.main200 : Colors.grey),
                                                                ))
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 15.0),
                                                        child: Container(
                                                          width: Get.width*0.3 + 1,
                                                          // height: Get.width*0.3,
                                                          child: MemberPickList(pickedMemberIndexList, (index) {
                                                            if(pickedMemberIndexList.contains(index)) {
                                                              pickedMemberIndexList.remove(index);
                                                            } else {
                                                              pickedMemberIndexList.add(index);
                                                            }
                                                          })
                                                          // MemberList(int.parse(number == null ? '0' : number[0]),),
                                                        ),),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Obx(
                                                () {
                                                  print('for obx : ${pickedMemberIndexList.length == needMemberNum.value}');
                                                  return Icon(
                                                  Icons.check_circle_outline,
                                                  color: imageFile != null && pickedMemberIndexList.length == needMemberNum.value ? AppColor.main200 : Colors.grey[400],
                                                );
                                                },
                                              ),
                                            ],
                                          ),
                                          // // 미팅 소개
                                          // Padding(
                                          //   padding: const EdgeInsets.only(top: 15.0, bottom: 8),
                                          //   child: Form(
                                          //     key: _formKeyIntroduce,
                                          //     child: TextFormField(
                                          //       cursorColor: Colors.red[100],
                                          //       validator: (value) {
                                          //         if (value.length > 500) {
                                          //           return '500자 초과';
                                          //         }
                                          //         return null;
                                          //       },
                                          //       controller: _introduceController,
                                          //       maxLength: 500,
                                          //       minLines: 5,
                                          //       maxLines: 15,
                                          //       decoration: InputDecoration(
                                          //         counterText: '',
                                          //         hintText: '미팅 구성원을 자유롭게 소개해주세요!',
                                          //         filled: true,
                                          //         fillColor: Colors.grey[50],
                                          //         enabledBorder: OutlineInputBorder(
                                          //           borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                          //           borderSide: BorderSide(color: Colors.grey[300]),
                                          //         ),
                                          //         focusedBorder: OutlineInputBorder(
                                          //           borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                          //           borderSide: BorderSide(color: Colors.grey[300]),
                                          //         ),
                                          //         border: OutlineInputBorder(),
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ),
                                          Padding(
                                            padding: const EdgeInsets.only(top : 15, bottom : 5),
                                            child: Text("※ 미팅은 생성 후 14일간 유지됩니다",
                                              style: TextStyle(fontFamily: "AppleSDGothicNeo",color: Colors.grey[600], fontSize: 13),),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.grey[300],
                    height: 1,
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                        child: Container(
                          height: 45,
                          child: Obx(
                            () {
                              print('for obx : ${pickedMemberIndexList.length == needMemberNum.value}');
                              return TextButton(
                              child: confirmTitle && (city1 != null) && (city2 != null) && (number != null) && (imageFile != null) && (pickedMemberIndexList.length == needMemberNum.value)
                                  ? Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    '20',
                                    style: TextStyle(
                                      color: Colors.red[200],
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Icon(
                                    Icons.favorite,
                                    color: Colors.red[200],
                                    size: 20,
                                  ),
                                ],
                              )
                                  : Text(
                                '미팅 만들기',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "AppleSDGothicNeoB",
                                  fontSize: 16,
                                ),
                              ),
                              style: BtStyle.sideLine,
                              onPressed: confirmTitle && (city1 != null) && (city2 != null) && (number != null) && (imageFile != null) && (pickedMemberIndexList.length == needMemberNum.value)
                                  ? () async {
                                await DatabaseService.instance.makeMeeting(
                                  title: this._titleController.text,
                                  number: int.parse(this.number.split(':')[0]),
                                  loc1: this.city1,
                                  loc2: this.city2,
                                  loc3: this._locationController.text,
                                  introduce: this._introduceController.text,
                                  imageFile: imageFile,
                                  memberList: pickedMemberIndexList.map((memberIndex) => user.memberList[memberIndex].toJson()).toList()
                                );

                                Map<String, dynamic> meeting = {
                                  "title": this._titleController.text,
                                  "number": int.parse(this.number.split(':')[0]),
                                  "loc1": this.city1,
                                  "loc2": this.city2,
                                  "loc3": this._locationController.text,
                                  "introduce": this._introduceController.text,
                                };

                                await DatabaseService.instance.useCoin(20, 1, newMeeting: meeting);
                                FocusScope.of(context).unfocus();
                                Navigator.pop(context);
                                CustomedFlushBar(Get.context, "등록이 완료되었습니다!");
                              } : null,
                            );
                            },
                          ),
                        ),
                      ),
                      Obx(
                        () {
                          print('for obx : ${pickedMemberIndexList.length == needMemberNum.value}');
                          return AnimatedCrossFade(
                          firstChild: Padding(
                            padding: EdgeInsets.only(left: Get.width*0.05, right: Get.width*0.05, bottom: 8),
                            child: TextField(
                              cursorColor: Colors.red[200],
                              controller: _introduceController,
                              maxLength: 500,
                              minLines: 5,
                              style: TextStyle(
                                fontFamily: "AppleSDGothicNeoM",
                              ),
                              maxLines: 10,
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: '미팅을 소개해주세요!',
                                hintStyle: TextStyle(
                                  fontFamily: "AppleSDGothicNeoM",
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
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
                          secondChild: Container(),
                          crossFadeState: confirmTitle && (city1 != null) && (city2 != null) && (number != null) && (imageFile != null) && (pickedMemberIndexList.length == needMemberNum.value) ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                          duration: const Duration(milliseconds: 100),
                        );
                        },
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String city1;

  Widget Cityt1() {
    return SmartSelect<String>.single(
      tileBuilder: (context, state) {
        return Flexible(
          child: TextFormField(
            onTap: state.showModal,
            readOnly: true,
            decoration: InputDecoration(
              //Icon이 오른쪽에 디폴트 패딩이 있어서 Row로 조정
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Icon(
                    Icons.check_circle_outline,
                    color: city1 != null ? AppColor.main200 : Colors.grey[400],
                  ),
                ],
              ),
              //사용가능일 때, border 색 지정(안해주면 theme color로 지정)
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[500]),
              ),
              // 텍스트 입력시 지워지는 hint 사용 (not label)
              hintStyle: TextStyle(color: city1 == null ? Colors.grey[600] : Colors.black, fontSize: 15, fontFamily: "AppleSDGothicNeoM"),
              hintText: city1 == null ? '시/도' : city1,
            ),
            style: TextStyle(fontFamily: "AppleSDGothicNeoM",),
          ),
        );
      },
      modalType: S2ModalType.popupDialog,
      title: '시/도',
      value: null,
      choiceItems: CityListDialog().options,
      onChange: (state) => setState(() {
        city1 = state.value;
        city2 = null;
      }),
    );
  }

  String city2;

  Widget City2(String city1) {
    List<S2Choice<String>> selectedOptions;

    switch (city1) {
      case '서울특별시':
        {
          selectedOptions = CityListDialog().options1;
        }
        break;

      case '부산광역시':
        {
          selectedOptions = CityListDialog().options2;
        }
        break;

      case '대구광역시':
        {
          selectedOptions = CityListDialog().options3;
        }
        break;

      case '인천광역시':
        {
          selectedOptions = CityListDialog().options4;
        }
        break;

      case '광주광역시':
        {
          selectedOptions = CityListDialog().options5;
        }
        break;

      case '대전광역시':
        {
          selectedOptions = CityListDialog().options6;
        }
        break;

      case '울산광역시':
        {
          selectedOptions = CityListDialog().options7;
        }
        break;

      case '경기도':
        {
          selectedOptions = CityListDialog().options8;
        }
        break;

      case '강원도':
        {
          selectedOptions = CityListDialog().options9;
        }
        break;

      case '충청북도':
        {
          selectedOptions = CityListDialog().options10;
        }
        break;

      case '충청남도':
        {
          selectedOptions = CityListDialog().options11;
        }
        break;

      case '세종특별자치시':
        {
          selectedOptions = CityListDialog().options12;
        }
        break;

      case '전라북도':
        {
          selectedOptions = CityListDialog().options13;
        }
        break;

      case '전라남도':
        {
          selectedOptions = CityListDialog().options14;
        }
        break;

      case '경상북도':
        {
          selectedOptions = CityListDialog().options15;
        }
        break;

      case '경상남도':
        {
          selectedOptions = CityListDialog().options16;
        }
        break;

      case '제주특별자치도':
        {
          selectedOptions = CityListDialog().options17;
        }
        break;

      default:
        {
          selectedOptions = CityListDialog().options0;
        }
        break;
    }

    return SmartSelect<String>.single(
      tileBuilder: (context, state) {
        return Flexible(
          child: TextFormField(
            onTap: state.showModal,
            readOnly: true,
            decoration: InputDecoration(
              //Icon이 오른쪽에 디폴트 패딩이 있어서 Row로 조정
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Icon(
                    Icons.check_circle_outline,
                    color: city2 != null ? AppColor.main200 : Colors.grey[400],
                  ),
                ],
              ),
              //사용가능일 때, border 색 지정(안해주면 theme color로 지정)
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[500]),
              ),
              // 텍스트 입력시 지워지는 hint 사용 (not label)
              hintStyle: TextStyle(color: city2 == null ? Colors.grey[600] : Colors.black, fontSize: 15, fontFamily: "AppleSDGothicNeoM"),
              hintText: city2 == null ? '시/군/구' : city2,
            ),
            style: TextStyle(fontFamily: "AppleSDGothicNeoM",),
          ),
        );
      },
      modalType: S2ModalType.popupDialog,
      title: '시/군/구',
      value: null,
      choiceItems: selectedOptions,
      onChange: (state) => setState(() {
        city2 = state.value;
      }),
    );
  }

  String number;

  Widget Number() {
    List<S2Choice<String>> optionsForAndroid = [
      S2Choice<String>(value: '1:1 (소개팅)', title: '1:1 (소개팅)'),
      S2Choice<String>(value: '2:2', title: '2:2'),
      S2Choice<String>(value: '3:3', title: '3:3'),
      S2Choice<String>(value: '4:4', title: '4:4'),
      S2Choice<String>(value: '5:5', title: '5:5'),
    ];

    List<S2Choice<String>> optionsForIOS = [
      S2Choice<String>(value: '1:1 (소개팅)', title: '1:1 (소개팅)'),
      S2Choice<String>(value: '2:2', title: '2:2'),
      S2Choice<String>(value: '3:3', title: '3:3'),
      S2Choice<String>(value: '4:4', title: '4:4'),
      S2Choice<String>(value: '5:5', title: '5:5'),
    ];

    return SmartSelect<String>.single(
      tileBuilder: (context, state) {
        return Flexible(
          child: TextFormField(
            onTap: state.showModal,
            readOnly: true,
            decoration: InputDecoration(
              //Icon이 오른쪽에 디폴트 패딩이 있어서 Row로 조정
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Icon(
                    Icons.check_circle_outline,
                    color: number != null ? AppColor.main200 : Colors.grey[400],
                  ),
                ],
              ),
              //사용가능일 때, border 색 지정(안해주면 theme color로 지정)
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[500]),
              ),
              // 텍스트 입력시 지워지는 hint 사용 (not label)
              hintStyle: TextStyle(color: number == null ? Colors.grey[600] : Colors.black, fontSize: 15, fontFamily: "AppleSDGothicNeoM"),
              hintText: number == null ? '미팅 인원' : number,
            ),
            style: TextStyle(fontFamily: "AppleSDGothicNeoM",),
          ),
        );
      },
      modalType: S2ModalType.popupDialog,
      title: '미팅 인원',
      value: null,
      choiceItems: Platform.isAndroid ? optionsForAndroid : optionsForIOS,
      onChange: (state) => setState(() {
        number = state.value;
        needMemberNum.value = int.parse(state.value[0]) - 1;
      }),
    );
  }

  File imageFile;
  Widget photoBox() {
    // // var pics = user.profileInfo['pics'];
    // var pic = '';
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: InkWell(
        onTap: () async {
          File aa = await Util.getImage();
          imageFile = aa;
          setState(() {});
        },
        child: Stack(
          children: [
            Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: imageFile == null ? Colors.grey : AppColor.main200, width: 1)),
                width: Get.width*0.3,
                height: Get.width*0.3,
                child: imageFile == null ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('센터', style: TextStyle(color: Colors.white)),
                      Icon(
                        Icons.add,
                        color: Colors.grey,
                      ),
                      Text('(파티 소개에\n쓰일 이미지)',
                          style: TextStyle(color: Colors.grey))
                    ]) : ClipRRect(
                  borderRadius: new BorderRadius.circular(7.0),
                  child: Image(
                      image: FileImage(imageFile),
                      width: Get.width*0.3,
                      height: Get.width*0.3,
                      fit: BoxFit.cover),
                )
            ),
          ],
        ),
      ),
    );
  }

}
