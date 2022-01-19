import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:byule/util/style/appColor.dart';

class BtStyle {
  BtStyle._();

  static ButtonStyle get textDialog => TextButton.styleFrom(
        primary: AppColor.main200,
        side: BorderSide(color: AppColor.main200, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 0,
        minimumSize: Size(Get.width * 0.55, 44),
      );

  static ButtonStyle get splash => ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Colors.white),
      overlayColor: MaterialStateProperty.all(Colors.black.withOpacity(0.05)),
      minimumSize: MaterialStateProperty.all(Size(0, 46)),
      shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))));

  static ButtonStyle get start => ButtonStyle(
        foregroundColor: MaterialStateProperty.all(Colors.white),
        overlayColor: MaterialStateProperty.all(Colors.white10),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) return Colors.grey;
          return AppColor.sub200;
        }),
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
        minimumSize: MaterialStateProperty.all(Size(80, 48)),
        textStyle: MaterialStateProperty.all(TextStyle(fontSize: 16)),
      );

  static ButtonStyle get standard => start.copyWith(
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
        minimumSize: MaterialStateProperty.all(Size(Get.width * 0.9, 44)),
      );

  static ButtonStyle get textSub100 => standard.copyWith(
        backgroundColor: MaterialStateProperty.all(AppColor.sub100),
      );

  static ButtonStyle get textSub200 => standard.copyWith(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) return Colors.grey;
          return AppColor.sub200;
        }),
      );

  static ButtonStyle get textMain100 => standard.copyWith(
        backgroundColor: MaterialStateProperty.all(AppColor.main100),
      );

  static ButtonStyle get textMain200 => standard.copyWith(
        backgroundColor: MaterialStateProperty.all(AppColor.main200),
      );

  static ButtonStyle get sideLine => standard.copyWith(
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled))
                return Colors.white;
              return AppColor.main200;
            }),
        overlayColor: MaterialStateProperty.resolveWith((states) => AppColor.main200.withOpacity(0.1)),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) return Colors.grey;
          return Colors.white;
        }),
        shape: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled))
            return RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6));
          return RoundedRectangleBorder(
              side: BorderSide(width: 1.5, color: AppColor.main200),
              borderRadius: BorderRadius.circular(6));
        }),
      );

  static ButtonStyle changeState(_buttonClicked) => ButtonStyle(
    minimumSize: MaterialStateProperty.all(Size(Get.width*0.9, 44)),
    foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (_buttonClicked) return AppColor.main200;
      return Colors.white;
    }),
    overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (_buttonClicked) return AppColor.main200.withOpacity(0.1);
      return Colors.white.withOpacity(0.1);
    }),
    backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (_buttonClicked) return Colors.white;
      return AppColor.main200;
    }),
    shape: MaterialStateProperty.resolveWith((states) {
      if (!_buttonClicked) return RoundedRectangleBorder(borderRadius: BorderRadius.circular(6));
      return RoundedRectangleBorder(
          side: BorderSide(width: 1.5, color: AppColor.main200),
          borderRadius: BorderRadius.circular(6));
    }),
    textStyle: MaterialStateProperty.all(TextStyle(fontSize: 16)),
  );

  static ButtonStyle get menu => ButtonStyle(
      foregroundColor: MaterialStateProperty.all(Colors.black87),
      overlayColor: MaterialStateProperty.all(Colors.black.withOpacity(0.05)),
      minimumSize: MaterialStateProperty.all(Size(Get.width * 0.9, 48)),
      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))));
}
