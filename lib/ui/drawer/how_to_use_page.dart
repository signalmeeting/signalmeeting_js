import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get/get.dart';
import 'package:signalmeeting/ui/drawer/custom_drawer.dart';

class HowToUsePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: drawerAppBar(context, '진행방법'),
      body: Stack(
        children: <Widget>[
          Container(
            color: Colors.white,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: Get.width * 0.05,
              ),
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: Get.width * 0.9,
                      child: ScrollConfiguration(
                        behavior: ScrollBehavior(),
                        child: GlowingOverscrollIndicator(
                          axisDirection: AxisDirection.right,
                          color: Colors.red[100],
                          child: Swiper.children(
                            loop: false,
                            children: [
                              Image.asset(
                                'assets/how_to_use1.png',
                                fit: BoxFit.fitWidth,
                              ),
                              Image.asset(
                                'assets/how_to_use2.png',
                                fit: BoxFit.fitWidth,
                              ),
                              Image.asset(
                                'assets/how_to_use3.png',
                                fit: BoxFit.fitWidth,
                              ),
                            ],
                            pagination: new SwiperPagination(
                              builder: new DotSwiperPaginationBuilder(
                                  color: Colors.white, activeColor: Colors.red[200]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: Get.width * 0.05,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
