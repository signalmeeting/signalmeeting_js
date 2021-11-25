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
import 'package:signalmeeting/controller/chat_controller.dart';
import 'package:signalmeeting/model/messageModel.dart';

class ChatPage extends StatelessWidget {
  ChatController get _chatController => Get.find(tag: Get.arguments);

  String get oppositeId => _chatController.oppositeId;

  String get oppositeName => _chatController.oppositeName;
  final TextEditingController _textController = new TextEditingController();

  DatabaseReference get reference => _chatController.messagesRef;

  bool get _isComposing => _chatController.isComposing.value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          title: Text(oppositeName, style: TextStyle(color: Colors.black)),
          centerTitle: true,
        ),
        body: Container(
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
        ));
  }

  FirebaseAnimatedList buildFirebaseList() {
    _chatController.messageList.clear();
    return FirebaseAnimatedList(
        query: reference,
        sort: (a, b) => b.key.compareTo(a.key),
        padding: EdgeInsets.all(8.0),
        reverse: true,
        itemBuilder: (_, DataSnapshot snapshot, Animation<double> animation, int index) {
          MessageModel message = MessageModel.fromJson(jsonDecode(jsonEncode(snapshot.value)));
          print("message : $message");
          bool _isComing = message.sender == oppositeId;
          print("index : $index" + " length : ${_chatController.messageList.length}");
          if (_chatController.messageList.length < index + 1 || index ==0) {
            _chatController.messageList.add(message.obs);
            if(index != 0 && message.theDay != _chatController.messageList[_chatController.messageList.indexWhere((element) => element.value == message) - 1].value.theDay)
              _chatController.messageList[index - 1].update((val) {
                val.showDate = true;
              });
          }
          return ChatMessage(message: _chatController.messageList.firstWhere((element) => element.value == message), animation: animation, isComing: _isComing);
        });
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(),
      child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: buildTakePhotoButton(),
            ),
            Flexible(
              child: buildSendTextField(),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: buildSendButton(),
            ),
          ])),
    );
  }

  Widget buildTakePhotoButton() {
    return IconButton(icon: Icon(Icons.photo_camera), onPressed: onTakePhotoButtonPressed);
  }

  Widget buildSendTextField() {
    return Obx(
      () => TextField(
        controller: _textController,
        onSubmitted: _isComposing ? _onSendMessageButtonPressed : null,
        onChanged: _handleChanged,
        decoration: InputDecoration.collapsed(hintText: "메세지 입력"),
      ),
    );
  }

  Widget buildSendButton() {
    return IconButton(icon: Icon(Icons.send), onPressed: () => _onSendMessageButtonPressed(_textController.text));
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
}

class ChatMessage extends StatelessWidget {
  final Rx<MessageModel> message;
  final Animation animation;
  final bool isComing;

  ChatMessage({this.message, this.animation, this.isComing});

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
        sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        axisAlignment: 0.0,
        child: Obx(
          () => Container(
            margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
            child: Column(
              children: [
                if (message.value.showDate ?? false)
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.max, children: [
                        Container(
                            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)), color: Colors.grey[400]),
                            child: Text(message.value.theDay,
                                style: const TextStyle(
                                    color: const Color(0xffffffff), fontWeight: FontWeight.w600, fontFamily: "AppleSDGothicNeo", fontStyle: FontStyle.normal, fontSize: 13.0)))
                      ])),
                buildMessageRow(),
              ],
            ),
          ),
        ));
  }

  Row buildMessageRow() {
    return Row(
      mainAxisAlignment: isComing ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (isComing)
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: buildAvatar(),
          ),
        SizedBox(width: 8.0),
        Column(
          crossAxisAlignment: isComing ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: <Widget>[buildMessageBody(), Opacity(opacity: 0.5, child: Text(message.value.timeString, style: TextStyle(color: Color(0xff131415), fontSize: 12)))],
        )
      ],
    );
  }

  CircleAvatar buildAvatar({String pic = ""}) {
    return pic.length > 0
        ? CircleAvatar(
            radius: 15,
            backgroundImage: NetworkImage(pic),
          )
        : CircleAvatar(
            radius: 15,
            backgroundColor: Colors.grey[300],
          );
  }

  Widget buildMessageBody() {
    return Opacity(
      opacity: 0.8,
      child: Container(
          padding: const EdgeInsets.only(top: 7, bottom: 7, left: 12, right: 12),
          child: Container(constraints: BoxConstraints(maxWidth: Get.width * .58), child: Text(message.value.text, style: TextStyle(color: Colors.black, fontSize: 16))),
          decoration: new BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isComing ? 0 : 12), topRight: Radius.circular(isComing ? 12 : 0), bottomRight: Radius.circular(12), bottomLeft: Radius.circular(12)))),
    );
  }

// Widget buildMessagePhoto() =>
//     Image.network(snapshot.value[Message.IMAGE_URL], width: 250.0);
}
