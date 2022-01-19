import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:byule/controller/chat_controller.dart';
import 'package:byule/model/messageModel.dart';
import 'package:byule/model/userModel.dart';
import 'package:byule/ui/home/opposite_profile.dart';
import 'package:byule/ui/widget/cached_image.dart';

class ChatPage extends StatelessWidget {
  ChatController get _chatController => Get.find(tag: Get.arguments);

  UserModel get oppositeUser => _chatController.oppositeUser;

  String get oppositeId => oppositeUser.uid;

  String get oppositeName => oppositeUser.name;

  final TextEditingController _textController = new TextEditingController();

  DatabaseReference get reference => _chatController.messagesRef;

  bool get _isComposing => _chatController.isComposing.value;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              highlightColor: Colors.black,
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            backgroundColor: Colors.white,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // avatarBySize(35),
                // SizedBox(width: 10,),
                Text(oppositeName, style: TextStyle(color: Colors.black)),
              ],
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              Container(
                child: Column(
                  children: <Widget>[
                    Flexible(
                      child: buildFirebaseList(),
                    ),
                    Divider(height: 1.0),
                    Container(
                      decoration: BoxDecoration(color: Theme.of(context).cardColor),
                      child: _buildTextComposer(),
                    ),
                  ],
                ),
              ),
              if(_chatController.messageList.isEmpty)
              Center(child: Padding(
                padding: EdgeInsets.only(bottom: Get.height*0.1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    avatarBySize(80),
                    SizedBox(height: 10,),
                    Text.rich(TextSpan(children: <TextSpan>[
                      TextSpan(
                        text: oppositeUser.name,
                        style: TextStyle(
                          fontFamily: 'AppleSDGothicNeoB',
                          fontSize: 20,
                        ),
                      ),
                      TextSpan(
                        text: '님과',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ])),
                    SizedBox(height: 3,),
                    Text('대화를 시작해보세요!', style: TextStyle(
                      // fontFamily: 'AppleSDGothicNeoM',
                      fontSize: 16,
                    ),),
                  ],
                ),
              ))

            ],
          )),
    );
  }

  FirebaseAnimatedList buildFirebaseList() {
    _chatController.messageList.clear();
    return FirebaseAnimatedList(
        query: reference,
        sort: (a, b) => b.key.compareTo(a.key),
        padding: EdgeInsets.all(8.0),
        reverse: true,
        itemBuilder:
            (_, DataSnapshot snapshot, Animation<double> animation, int index) {
          MessageModel message =
              MessageModel.fromJson(jsonDecode(jsonEncode(snapshot.value)));
          bool _isComing = message.sender == oppositeId;
          if (_chatController.messageList.length < index + 1 || index == 0) {
            _chatController.messageList.add(message.obs);
            if (index != 0 &&
                message.theDay !=
                    _chatController
                        .messageList[_chatController.messageList.indexWhere(
                                (element) => element.value == message) -
                            1]
                        .value
                        .theDay)
              _chatController.messageList[index - 1].update((val) {
                val.showDate = true;
              });
          }
          return ChatMessage(
            message: _chatController.messageList
                .firstWhere((element) => element.value == message),
            animation: animation,
            isComing: _isComing,
            oppositeUser: _isComing ? oppositeUser : null,
          );
        });
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(),
      child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(children: <Widget>[
            Flexible(
              child: buildSendTextField(),
            ),
            buildSendButton(),
          ])),
    );
  }

  Widget buildSendTextField() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: TextField(
          style: TextStyle(fontSize: 16),
          controller: _textController,
          onSubmitted: _isComposing ? _onSendMessageButtonPressed : null,
          onChanged: _handleChanged,
          decoration: InputDecoration.collapsed(hintText: "메세지 입력"),
        ),
      ),
    );
  }

  Widget buildSendButton() {
    return IconButton(
        icon: Icon(Icons.arrow_forward_ios_rounded),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onPressed: () => _onSendMessageButtonPressed(_textController.text));
  }

  Future onTakePhotoButtonPressed() async {
    File imageFile = await ImagePicker.pickImage();
    String imageFileName = createImageFileName();
    String downloadUrl = await uploadPhoto(imageFileName, imageFile);
    _sendMessage(imageUrl: downloadUrl);
  }

  Future<String> uploadPhoto(String imageFileName, File imageFile) async {
    Reference reference = FirebaseStorage.instance.ref().child(imageFileName);
    UploadTask uploadTask = reference.putFile(imageFile);
    String downloadUrl;
    await uploadTask.whenComplete(() async {
      await reference.getDownloadURL().then((fileURL) {
        downloadUrl = fileURL;
      });
    });
    return downloadUrl;
  }

  Future<Null> _onSendMessageButtonPressed(String text) async {
    if (_isComposing) {
      _textController.clear();
      _chatController.isComposing.value = false;
      _sendMessage(text: text);
    }
  }

  void _sendMessage({String text, String imageUrl}) {
    _chatController.sendMessage(text);
    // analytics.logEvent(name: Analytics.SEND_MESSAGE_EVENT);
  }

  void _handleChanged(String text) {
    _chatController.isComposing.value = text.length > 0;
  }

  String createImageFileName() {
    int random = Random().nextInt(100000);
    return "image_$random.jpg";
  }

  Widget avatarBySize(double double) {
    return GestureDetector(
      onTap: () => Get.to(
            () => OppositeProfilePage(oppositeUser, isItFromChat: true),
        arguments: Get.arguments,
      ),
      child: oppositeUser.pics.length > 0
          ? cachedImage(oppositeUser.firstPic,
          width: double, height: double, radius: double)
          : CircleAvatar(
        radius: double,
        backgroundColor: Colors.grey[200],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final Rx<MessageModel> message;
  final Animation animation;
  final bool isComing;
  final UserModel oppositeUser;

  ChatMessage({this.message, this.animation, this.isComing, this.oppositeUser});

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
        sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        axisAlignment: 0.0,
        child: Obx(
          () => Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Column(
              children: [
                if (message.value.showDate ?? false)
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 8.0),
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                    color: Colors.grey[400]),
                                child: Text(message.value.theDay,
                                    style: const TextStyle(
                                        color: const Color(0xffffffff),
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "AppleSDGothicNeo",
                                        fontStyle: FontStyle.normal,
                                        fontSize: 13.0)))
                          ])),
                buildMessageRow(),
              ],
            ),
          ),
        ));
  }

  Row buildMessageRow() {
    return Row(
      mainAxisAlignment:
          isComing ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (isComing) buildAvatar(),
        SizedBox(width: 8.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            if (!isComing) _buildTime(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: buildMessageBody(),
            ),
            if (isComing) _buildTime()
          ],
        )
      ],
    );
  }

  Opacity _buildTime() => Opacity(
      opacity: 0.5,
      child: Text(message.value.timeString,
          style: TextStyle(color: Color(0xff131415), fontSize: 12)));

  Widget buildAvatar() {
    return GestureDetector(
      onTap: () => Get.to(
        () => OppositeProfilePage(oppositeUser, isItFromChat: true),
        arguments: Get.arguments,
      ),
      child: oppositeUser.pics.length > 0
          ? cachedImage(oppositeUser.firstPic,
              width: 35, height: 35, radius: 30.0)
          : CircleAvatar(
              radius: 15,
              backgroundColor: Colors.grey[200],
            ),
    );
  }

  Widget buildMessageBody() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
          padding:
              const EdgeInsets.only(top: 7, bottom: 7, left: 12, right: 12),
          child: Container(
              constraints: BoxConstraints(maxWidth: Get.width * .58),
              child: Text(message.value.text,
                  style: TextStyle(color: Colors.black, fontSize: 16))),
          decoration: new BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isComing ? 0 : 12),
                  topRight: Radius.circular(isComing ? 12 : 0),
                  bottomRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12)))),
    );
  }

// Widget buildMessagePhoto() =>
//     Image.network(snapshot.value[Message.IMAGE_URL], width: 250.0);
}
