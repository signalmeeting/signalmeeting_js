import 'dart:async';
import 'package:byule/ui/lobby.dart';
import 'package:flutter/material.dart';

import 'util/style/appColor.dart';

class SplashAnimation extends StatefulWidget {
  bool hasData;
  SplashAnimation(this.hasData);

  @override
  _SplashAnimationState createState() => _SplashAnimationState();
}

class _SplashAnimationState extends State<SplashAnimation> with TickerProviderStateMixin {
  AnimationController scaleController;
  Animation<double> scaleAnimation;

  double _opacity = 0;
  bool _value = true;

  @override
  void initState() {
    super.initState();

    scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    )..addStatusListener(
          (status) {
        if (status == AnimationStatus.completed&&widget.hasData) {
          Navigator.of(context).pushReplacement(
            ThisIsFadeRoute(
              route: LobbyPage(),
            ),
          );
        } else if (status == AnimationStatus.completed&&!widget.hasData) {
          Timer(
            Duration(milliseconds: 300),
                () {
              scaleController.reset();
            },
          );
        }
      },
    );

    scaleAnimation = Tween<double>(begin: 0.0, end: 12).animate(scaleController);

    Timer(Duration(milliseconds: 600), () {
      setState(() {
        _opacity = 1.0;
        _value = false;
      });
    });
    Timer(Duration(milliseconds: 2000), () {
      setState(() {
        scaleController.forward();
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: AnimatedOpacity(
              curve: Curves.fastLinearToSlowEaseIn,
              duration: Duration(seconds: 6),
              opacity: _opacity,
              child: AnimatedContainer(
                curve: Curves.fastLinearToSlowEaseIn,
                duration: Duration(seconds: 2),
                height: _value ? 100 : 300,
                width: _value ? 100 : 300,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(.3),
                      blurRadius: 300,
                      spreadRadius: 20,
                    ),
                  ],
                  // color: Colors.blue,
                  borderRadius: BorderRadius.circular(300),
                ),
                child: Image.asset('assets/start_page.png'),
                // child: Center(
                //   child: Container(
                //     width: 100,
                //     height: 100,
                //     decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                //     child: AnimatedBuilder(
                //       animation: scaleAnimation,
                //       builder: (c, child) => Transform.scale(
                //         scale: scaleAnimation.value,
                //         child: Container(
                //           decoration: BoxDecoration(
                //             shape: BoxShape.circle,
                //             color: Colors.red,
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ThisIsFadeRoute extends PageRouteBuilder {
  final Widget page;
  final Widget route;

  ThisIsFadeRoute({this.page, this.route})
      : super(
    pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) =>
    page,
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) =>
        FadeTransition(
          opacity: animation,
          child: route,
        ),
  );
}

