import 'dart:ui';
import 'dart:ui' as ui show Image;

import 'package:flutter/material.dart';
import 'package:puzzle/model/puzzle_tile.dart';

class PuzzlePainter extends CustomPainter {
  final double x, y;
  final List<PuzzleTile> puzzles;
  TextSpan textSpan;
  TextPainter textPainter;

  PuzzlePainter({this.x, this.y, this.puzzles});

  @override
  void paint(Canvas canvas, Size size) {

    if (puzzles != null) {
      puzzles.shuffle();

      for (int i = 0; i < puzzles.length; i++) {
        PuzzleTile item = puzzles[i];
        if (i ==i) {
//          canvas.drawImage(item.image,
//              Offset(item.rectScreen.left, item.rectScreen.top), Paint());
          Rect rect =
              Rect.fromLTWH(0, 0, item.image.width.toDouble(), item.image.height.toDouble());
          Rect rect1 = Rect.fromLTWH(
              (16 + item.rectScreen.width*(i%2)).toDouble(), (16 + item.rectScreen.height * (i~/2)).toDouble(), item.rectScreen.width, item.rectScreen.height);
          canvas.drawImageRect(
              item.image, rect, rect1, Paint()..color = Colors.red);
        }
        textSpan = new TextSpan(
            text: '${item.rectScreen.left}-${item.rectScreen.top}',
            style: TextStyle(color: Colors.red));
        textPainter =
            new TextPainter(text: textSpan, textDirection: TextDirection.ltr);
        textPainter.layout(minWidth: 30, maxWidth: 50);
        textPainter.paint(
            canvas, Offset(item.rectScreen.left, item.rectScreen.top));
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
