import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:byule/util/util.dart';
import 'dart:math';

class DailyTesting extends StatefulWidget {

  @override
  _DailyTestingState createState() => _DailyTestingState();
}

class _DailyTestingState extends State<DailyTesting> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  var randomPhone = new Random();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("test"),
        actions: [
          TextButton(
            child: Text("+남자",
              style: TextStyle(
                color: Colors.red
              ),
            ),
            onPressed: (){
              addDummyUser(true);
            },
          ),
          TextButton(
            child: Text("+여자",
              style: TextStyle(
                  color: Colors.red
              ),
            ),
            onPressed: (){
              addDummyUser(false);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection('users').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          int men = 0;
          int women = 0;
          List totalUser = [];
          if(snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator(),);
          snapshot.data.docs.forEach((DocumentSnapshot data) {
            String uid = data.id;
            Map<String, dynamic> userdata = data.data();
            userdata['userid'] = uid;
            totalUser.add(userdata);
            if(data.data()['profileInfo']['man'])
              men += 1;
            else
              women += 1;
          });
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("총 인원 : " + totalUser.length.toString()),
              Text("남자 : " + men.toString()),
              Text("여자 : " + women.toString()),
              StreamBuilder<QuerySnapshot>(
                stream: db.collection('todayMatch').doc(Util.todayMatchDateFormat(DateTime.now())).collection('matches').snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  int dailyMeeting = 0;
                  List _totalDailyMeeting = [];
                  if(snapshot.connectionState == ConnectionState.waiting)
                    return Center(child : CircularProgressIndicator());
                  if(!snapshot.hasData)
                    return Text("none");
                  snapshot.data.docs.forEach((e) {
                    _totalDailyMeeting.add(e.data());
                  });
                  return Expanded(
                      child: Container(
                        child: ListView.builder(
                            itemCount: totalUser.length,
                            itemBuilder: (BuildContext context ,int index){
                              return FutureBuilder(
                                  future: checkDailyMeeting(totalUser[index]['profileInfo']['man'], totalUser[index]['userid'] , _totalDailyMeeting),
                                  builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                                    return ListTile(
                                      leading: Text((index + 1).toString() ),
                                      title: Column(
                                        children: <Widget>[
                                          Text(totalUser[index]['profileInfo']['name']
                                              + " / "
                                              + (totalUser[index]['profileInfo']['man'] ? "남" : "여")
                                              + "/ 데일리 미팅 : "
                                              + snapshot.data.toString()
                                          ),
                                          Text(totalUser[index]['userid'])
                                        ],
                                      ),
                                    );
                                  }
                              );
                            }),
                      )
                  );
                }
              ),
            ],
          );
        }
      ),
    );
  }

  Future<int> checkDailyMeeting(bool man, String uid, List dailyMeeting,) {
    int cnt = 0;
    man ? dailyMeeting.forEach((e) {
      if(e['men'].contains(uid))
        cnt += 1;
    }) :
    dailyMeeting.forEach((e) {
      if(e['women'].contains(uid))
        cnt += 1;
    });
    return Future.value(cnt);
  }

  addDummyUser(bool man) async{
    Map<String, dynamic> testUser = {
      "coin" : 5,
      "invite" : false,
      "phone" : "8210000" + randomPhone.nextInt(9999).toString(),
      "profileInfo" : {
        "age" : 25,
        "bodyType" : "근육있는",
        "career" : "취업준비생",
        "drink" : "전혀안함",
        "introduce" : "test",
        "loc1" : "서울",
        "loc2" : "전체",
        "man" : man ? true : false,
        "name" : man ? "testman" : "testwoman"
      },
      "pics" : [],
      "tall" : 180,
      "pushInfo" : {},
      "stop" : false,
    };
    await db.collection('users').add(testUser);
  }
}
