import 'package:flutter/material.dart';

class GameDialogAnimate extends StatelessWidget {
  final Widget child;
  final Animation animation;

  GameDialogAnimate({this.child, this.animation});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Center(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          print(animation.value);
          return Transform(
            transform:
                Matrix4.translationValues(0.0, animation.value * height, 0.0),
            child: Container(
              child: child,
            ),
          );
        },
        child: child,
      ),
    );
  }
}
