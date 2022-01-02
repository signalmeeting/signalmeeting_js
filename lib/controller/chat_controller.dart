import 'dart:async';

import 'package:byule/model/userModel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:byule/controller/main_controller.dart';
import 'package:byule/model/messageModel.dart';
import 'package:byule/model/userModel.dart';

class ChatController extends GetxController {
  final String roomId;
  final UserModel oppositeUser;
  final String type;

  ChatController(this.roomId, this.oppositeUser, this.type);

  final MainController _mainController = Get.find();

  
  DatabaseReference messagesRef;
  // StreamSubscription<Event> _messagesSubscription;

  Rx<String> error = null.obs;
  RxBool isComposing = false.obs;
  Rx<MessageModel> newMessage = MessageModel().obs;
  RxList<Rx<MessageModel>> messageList = <Rx<MessageModel>>[].obs;

  @override
  void onInit() {
    final FirebaseDatabase database = FirebaseDatabase(app: _mainController.app);
    messagesRef = database.reference().child(roomId);

    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(10000000);
    messagesRef.keepSynced(true);
    // _messagesSubscription = messagesRef.limitToLast(10).onChildAdded.listen((Event event) {
    //   print('Child added: ${event.snapshot.value}');
    // }, onError: (Object o) {
    //   final DatabaseError _error = o;
    //   print('Error: ${_error.code} ${_error.message}');
    //   error.value = _error.message;
    // });
    super.onInit();
  }

  @override
  void onClose() {
    // _messagesSubscription.cancel();
    super.onClose();
  }

  sendMessage(String text) {
    newMessage.update((val) {
      val.sender = _mainController.user.value.uid;
      val.receiver = oppositeUser.uid;
      val.text = text;
      val.type = type;
      val.time = DateTime.now();
    });
    messagesRef.push().set(newMessage.toJson());
  }
}