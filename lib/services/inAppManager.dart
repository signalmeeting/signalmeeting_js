import 'dart:async';
import 'dart:io';
import 'package:byule/controller/main_controller.dart';
import 'package:byule/services/database.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:get/get.dart';

import 'database.dart';

final List<String> _productLists = Platform.isAndroid? ['coin10','coin30', 'coin50', 'coin110']
    : ['coin10','coin30', 'coin50', 'coin110'].map((item) =>'com.signalmeeting.'+item).toList();

class InAppManager {
  MainController _mainController = Get.find();

  init() async {
    await FlutterInappPurchase.instance.initConnection;
    dynamic productList=  await FlutterInappPurchase.instance.getProducts(_productLists); //상품 목록 로드 , 아이폰은 구독로드가 따로 없음 (~11.2)
    print("productList : $productList");
    FlutterInappPurchase.purchaseUpdated.listen((productItem) {
      print('purchase-updated: $productItem');
      // 구매성공 했을때 들어오는곳
      if (productItem != null)
        consumePurchase(productItem);
      else
        print("error occurs");
    });
    FlutterInappPurchase.purchaseError.listen((purchaseError) {
      //구매 취소했을경우나 에러
      print('purchase-error: $purchaseError');
    });
    consumeAllPurchases(); //남아있는 아이템 확인//아이템 하나도 없을경우
  }

  consumeAllPurchases() async {
    //남아있는 아이템 컨슘
    print('consumeAllPurchases');
    List<PurchasedItem> purchases = await FlutterInappPurchase.instance
        .getAvailablePurchases(); //Get all purchases made by the user (either non-consumable, or haven't been consumed yet)
    if (purchases.length > 0) {
      List<PurchasedItem> coinItems = purchases.where((element) => element.productId.startsWith('coin')).toList();
      if (coinItems != null) {
        print("coinItems : $coinItems");
        for (var item in coinItems) {
          //코인은 발급하고 소진 시켜야됨
          consumePurchase(item);
        }
      }
    }
  }

  void requestPurchase(String productId) {
    print('productId $productId');
    FlutterInappPurchase.instance.requestPurchase(productId);
  }

  Future<bool> consumePurchase(PurchasedItem purchasedItem) async {
    print('consumePurchase start');
    Map<String, dynamic> resultMap = await DatabaseService.instance.purchaseReceipt(purchasedItem);
    print('consumePurchase done');
    print('abcd $resultMap');
    if (resultMap['result']) {
      _mainController.addCoin(resultMap['coin']);
      await FlutterInappPurchase.instance.finishTransaction(purchasedItem, isConsumable: (purchasedItem.productId.startsWith('coin')));
    }
    return resultMap['result'];
  }
}