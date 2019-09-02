import 'dart:ui';

import 'package:flutter/material.dart';

class PuzzlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromLTWH(0, 0, double.infinity, double.infinity);
    canvas.drawRect(rect, Paint()..color = Colors.red);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}
