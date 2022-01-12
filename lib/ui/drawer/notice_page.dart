import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:byule/model/noticeModel.dart';
import 'package:byule/services/database.dart';

import 'custom_drawer.dart';

class NoticePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: drawerAppBar(context, '공지사항'),
      body: FutureBuilder<Object>(
          future: DatabaseService.instance.getNotices(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());
            else {
              List<DocumentSnapshot> resultList = snapshot.data;
              List<NoticeModel> noticeList = resultList.map<NoticeModel>((DocumentSnapshot e) {
                Map data = e.data();
                data["id"] = e.id;
                data["time"] = data["time"].toDate().toString();
                return NoticeModel.fromJson(data);
              }).toList();
              return ScrollConfiguration(
                behavior: ScrollBehavior(),
                child: GlowingOverscrollIndicator(
                    axisDirection: AxisDirection.down,
                    color: Colors.white,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: noticeList.length,
                      itemBuilder: (BuildContext context, int index) {
                        NoticeModel notice = noticeList[index];
                        return NoticeForm(notice.title, notice.date, notice.body);
                      },
                    )),
              );
            }
          }),
    );
  }

  Widget NoticeForm(title, when, content) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]),
          )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 18.0, top: 10, right: 18),
            child: Container(
                alignment: Alignment.bottomLeft,
                child: Text(
                  '$title',
                  style: TextStyle(fontSize: 16),
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 18.0, top: 5, bottom: 10),
            child: Container(
              alignment: Alignment.topLeft,
              child: Text(
                "$when",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 18.0, top: 5, bottom: 10),
            child: Container(
              alignment: Alignment.topLeft,
              child: Text(
                "$content",
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
