import 'package:button3d/button3d.dart';
import 'package:flutter/material.dart';

class GameButton extends StatelessWidget {
  final VoidCallback onPress;
  final String label;

  GameButton({@required this.onPress, this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      child: Button3d(
        style: Button3dStyle(
          topColor: Colors.amber,
          backColor: Colors.orangeAccent,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        onPressed: onPress,
        child: Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.black),
        ),
      ),
    );
  }
}
