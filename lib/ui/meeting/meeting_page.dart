import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:byule/controller/meeting_controller.dart';
import 'package:byule/model/meetingModel.dart';
import 'package:byule/model/userModel.dart';
import 'package:byule/services/database.dart';
import 'package:byule/ui/meeting/make_meeting_page.dart';
import 'package:byule/ui/widget/dialog/city_list_dialog.dart';
import 'package:byule/ui/widget/dialog/noCoinDialog.dart';
import 'package:byule/ui/widget/meeting/meetingGrid.dart';
import 'package:byule/util/style/btStyle.dart';
import 'package:smart_select/smart_select.dart';
import 'my_meeting_page.dart';

class MeetingPage extends StatefulWidget {
  @override
  _MeetingPageState createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  final ScrollController scrollController = ScrollController();

  MeetingController _c = Get.put(MeetingController());

  UserModel get user => _c.user;

  String get _loc1 => _c.loc1.value;

  String get _loc2 => _c.loc2.value;

  int get _type => _c.type.value;

  bool get isFiltered => _loc1 != '전체' || _loc2 != '전체' || _type != 0;

  @override
  Widget build(BuildContext context) {

    return Obx(
      () => Stack(
        children: [
          //filter 에서 _loc2 를 구독을 못하길래 확인해보려고 텍스트 값 하나 띄워봤는데 갑자기 구독함 ㅋㅋㅋ 뭐냐 이거
          //아래 컬럼 안에 넣어서 있고 없고 차이 봐바
          Text(_loc2),
          Container(color: Colors.white),
          Column(
            children: <Widget>[
              buildFilter(),
              Expanded(
                child: Container(
                  width: Get.width * 0.96,
                  // child: isFiltered ? buildMeetingListFilter() : buildMeetingListTotal(),
                  child: buildMeetingListTotal(),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: Get.width * 0.02),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    makeMeetingButton(),
                    SizedBox(
                      width: Get.width * 0.02,
                    ),
                    myMeetingButton(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildFilter() {
    return Padding(
      padding: EdgeInsets.all(Get.width * 0.02),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.horizontal(left: Radius.circular(6)),
                  border: Border.all(color: Colors.grey, width: 0.4),
                  color: Colors.grey[50]),
              child: selectLocation1(),
            ),
          ),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.horizontal(right: Radius.circular(6)),
                  border: Border.all(color: Colors.grey, width: 0.4),
                  color: Colors.grey[50]),
              child: selectLocation2(),
            ),
          ),
          Container(
            width: Get.width * 0.02,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey, width: 0.4),
                  color: Colors.grey[50]),
              height: 40,
              child: selectType(),
            ),
          ),
        ],
      ),
    );
  }

  Widget selectLocation1() => SmartSelect<String>.single(
        tileBuilder: (context, state) {
          return InkWell(
            onTap: state.showModal,
            child: Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          '$_loc1',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700], fontFamily: "AppleSDGothicNeoM",),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey[500],
                      size: 20,
                    ),
                  ),
                ],
              ),
              color: Colors.transparent,
            ),
          );
        },
        modalType: S2ModalType.popupDialog,
        title: '시/도',
        value: '전체',
        choiceItems:
            List.generate(CityListDialog().options.length + 1, (index) {
          if (index == 0)
            return S2Choice<String>(value: '전체', title: '전체');
          else
            return CityListDialog().options[index - 1];
        }),
//            CityListInfo().city1.length, (index) => S2Choice(value: CityListInfo().city1[index], title: CityListInfo().city1[index])),
        onChange: (state) {
          if (_loc1 != state.value) _c.selectLocation1(state.value, () {});
        },
      );

  Widget selectLocation2() {
    List<S2Choice<String>> cityList;

    switch (_loc1) {case '전체':{cityList = CityListDialog().options0;}break;case '서울특별시':{cityList = CityListDialog().options1;}break;case '부산광역시':{cityList = CityListDialog().options2;}break;case '대구광역시':{cityList = CityListDialog().options3;}break;case '인천광역시':{cityList = CityListDialog().options4;}break;case '광주광역시':{cityList = CityListDialog().options5;}break;case '대전광역시':{cityList = CityListDialog().options6;}break;case '울산광역시':{cityList = CityListDialog().options7;}break;case '경기도':{cityList = CityListDialog().options8;}break;case '강원도':{cityList = CityListDialog().options9;}break;case '충청북도':{cityList = CityListDialog().options10;}break;case '충청남도':{cityList = CityListDialog().options11;}break;case '세종특별자치시':{cityList = CityListDialog().options12;}break;case '전라북도':{cityList = CityListDialog().options13;}break;case '전라남도':{cityList = CityListDialog().options14;}break;case '경상북도':{cityList = CityListDialog().options15;}break;case '경상남도':{cityList = CityListDialog().options16;}break;case '제주특별자치시도':{cityList = CityListDialog().options17;}break;default:{cityList = CityListDialog().options0;}break;}

    return SmartSelect<String>.single(
      tileBuilder: (context, state) {
        //City1이 변경 된 후, City2 필터의 현재 값을 재설정 해주고 가야함.
        if (_loc2 == '전체') {
          state.value = '전체';
        }
        return InkWell(
          onTap: state.showModal,
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        '$_loc2',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[700], fontFamily: "AppleSDGothicNeoM",),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey[500],
                    size: 20,
                  ),
                ),
              ],
            ),
            color: Colors.transparent,
          ),
        );
      },
      modalType: S2ModalType.popupDialog,
      title: '시/군/구',
      value: '전체',
      choiceItems: List.generate(cityList.length, (index) {
        if (index == 0)
          return S2Choice<String>(value: '전체', title: '전체');
        else
          return cityList[index];
      }),
      onChange: (state) {
        if (_loc2 != state.value) _c.selectLocation2(state.value, () {});
      },
    );
  }

  Widget selectType() {
    List<String> _typeOptions = ['전체', '신청 가능'];
    return SmartSelect<int>.single(
        tileBuilder: (context, state) {
          return GestureDetector(
            onTap: state.showModal,
            child: Container(
              alignment: Alignment.center,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          '${_typeOptions[_type]}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700], fontFamily: "AppleSDGothicNeoM",),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey[500],
                      size: 20,
                    ),
                  ),
                ],
              ),
              color: Colors.transparent,
            ),
          );
        },
        modalType: S2ModalType.popupDialog,
        title: '신청 상태',
        value: _type,
        choiceItems: List.generate(_typeOptions.length,
            (index) => S2Choice(value: index, title: _typeOptions[index])),
        onChange: (state) {
          if (_type != state.value) _c.selectType(state.value, () {});
        });
  }

  Widget buildMeetingListTotal() {
    return StreamBuilder<QuerySnapshot>(
        stream: DatabaseService.instance.getTotalMeetingList(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          else
            return buildMeetingList(snapshot.data.docs);
        });
  }

  // Widget buildMeetingListFilter() {
  //   return StreamBuilder<QuerySnapshot>(
  //       stream: DatabaseService.instance.getMeetingListFilter(loc1: this._loc1, loc2: this._loc2, type: this._type),
  //       builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
  //         if (snapshot.connectionState == ConnectionState.waiting)
  //           return Center(child: CircularProgressIndicator());
  //         else if (snapshot.data == null) return Container();
  //         else  return buildMeetingList(snapshot.data.docs);
  //       });
  // }

  Widget buildMeetingList(List<QueryDocumentSnapshot> docs) {
    if (docs.length > 0) {
      List<MeetingModel> meetingList = [];
      docs.map((QueryDocumentSnapshot e) async{
        Map<String, dynamic> meeting = e.data();
        meeting["_id"] = e.id;
        meeting["isMine"] = meeting["userId"] == user.uid;
        meeting['createdAt'] = meeting['createdAt'].toDate().toString();
        //신고 3번 먹으면 노출 안되게
        if(meeting['banList'].length > 2) {
          return;
        }

        //인창 수정
        if (isFiltered) {
          if ((this._loc1 == '전체' || this._loc1 == meeting["loc1"]) &&
              (this._loc2 == '전체' || this._loc2 == meeting["loc2"]) &&
              (this._type == 0 ||
                  (user.profileInfo['man'] ? meeting["man"] == false : meeting["man"] == true) && meeting["process"] == null ||
                  (user.profileInfo['man'] ? meeting["man"] == false : meeting["man"] == true) && meeting["process"] == 2))
            {
              meetingList.add(MeetingModel.fromJson(meeting));
            }
        } else {
          return meetingList.add(MeetingModel.fromJson(meeting));
        }
      }).toList();
      return ScrollConfiguration(
        behavior: ScrollBehavior(),
        child: GlowingOverscrollIndicator(
            axisDirection: AxisDirection.down,
            color: Colors.red[50],
            child: meetingGrid(meetingList, user.uid)
        ),
      );
    } else
      return Container();
  }

  Widget makeMeetingButton() {
    return Container(
      height: 46,
      width: Get.width * 0.47,
      child: TextButton(
        child: Text(
          '미팅 등록',
        ),
        style: BtStyle.textMain200,
        onPressed: () => (user.coin < 20) ? Get.dialog(NoCoinDialog()) : Get.to(() => MakeMeetingPage()),
      ),
    );
  }

  Widget myMeetingButton() {
    return Container(
      height: 46,
      width: Get.width * 0.47,
      child: TextButton(
        child: Text(
          '내 미팅',
        ),
        style: BtStyle.textMain200,
        onPressed: () => Get.to(() => MyMeetingPage()),
      ),
    );
  }
}
