import 'package:byule/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:byule/util/style/appColor.dart';

class AdminPage extends StatefulWidget {

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController nickController = TextEditingController();
  List searchedUser = [];
  @override
  void initState() {
    nickController.text = "";
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AdminPage"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: DatabaseService.instance.userCollection.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(child: CircularProgressIndicator(),);
            }
            int woman = 0;
            int man = 0;
            snapshot.data.docs.forEach((e) {
              if(!e.data()['uid'].contains("dummy")){
                e.data()['profileInfo']['man'] ? man += 1 : woman += 1;
              }
            });
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("남자 : ${man.toString()}"),
                Text("여자 : ${woman.toString()}"),
                Text("유저 검색(닉네임)"),
                Row(
                  children: <Widget>[
                    Flexible(
                      fit: FlexFit.tight,
                      child: TextField(
                        controller: nickController,
                      ),
                    ),
                    TextButton(
                      child: Text("찾기"),
                      onPressed: () async{
                        searchedUser = await DatabaseService.instance.findUid(nickController.text);
                        setState(() {
                          searchedUser = searchedUser;
                        });
                        nickController.text = "";
                      },
                    )
                  ],
                ),
                Container(
                  height: Get.height / 5,
                  child: ListView.builder(
                      itemCount: searchedUser.length,
                      itemBuilder: (BuildContext context, int index){
                        return ListTile(
                          title: Column(
                            crossAxisAlignment:CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("닉네임 : ${searchedUser[index]["profileInfo"]['name']}")
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              TextButton(child : Text("코인추가"), onPressed : () async{
                                await DatabaseService.instance.adminAddCoin(searchedUser[index]["uid"]);
                              }),
                              TextButton(child: Text("탈퇴"), onPressed: () async{
                                await DatabaseService.instance.adminWithDraw(searchedUser[index]["uid"]);
                                setState(() {
                                  searchedUser = [];
                                });
                              },),
                            ],
                          ),
                          subtitle: Text("${searchedUser[index]["profileInfo"]['man'] ? "남" : "여"} / ${searchedUser[index]["phone"]}"),
                        );
                      }),
                ),
                TextButton(
                  child: Text("test"),
                  onPressed : () => Get.dialog(Center(child: CircularProgressIndicator(
                    color: AppColor.main100,
                  ),))
                ),
                // Container(
                //   height : Get.width / 5,
                //   //color: Colors.red,
                //   child: Center(child : CircularProgressIndicator(
                //     color: AppColor.main200,
                //   )),
                // ),
              ],
            );
          }
        ),
      ),
    );
  }
}
