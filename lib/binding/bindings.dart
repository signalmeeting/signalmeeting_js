import 'package:byule/controller/meeting_opposite_profile_controller.dart';
import 'package:byule/model/userModel.dart';
import 'package:get/get.dart';

class MeetingOppositeProfileBinding extends Bindings {
  void dependencies() {
    Get.lazyPut(() => MeetingOppositeProfileController(Get.arguments["meetingId"], Get.arguments["user"] as UserModel));
  }
}