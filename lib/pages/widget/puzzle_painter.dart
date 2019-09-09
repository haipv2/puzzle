import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:puzzle/model/puzzle_tile.dart';

class PuzzlePainter extends CustomPainter {
  final double paddingX, paddingY;
  final List<PuzzleTile> puzzles;
  TextSpan textSpan;
  TextPainter textPainter;
  Rect rectExt;
  bool reDraw;

  PuzzlePainter({this.paddingX, this.paddingY, this.puzzles, this.rectExt, this.reDraw: false});

  @override
  void paint(Canvas canvas, Size size) {
    if (puzzles != null) {
      canvas.drawRect(rectExt, Paint()..color = Colors.white);
      puzzles.shuffle();
      for (int i = 0; i < puzzles.length; i++) {
        PuzzleTile item = puzzles[i];
        Rect rect = Rect.fromLTWH(
            0, 0, item.image.width.toDouble(), item.image.height.toDouble());
        Rect rect1 = Rect.fromLTWH(
            (paddingX + item.rectScreen.width * (i % 2)).toDouble(),
            (paddingY + item.rectScreen.height * (i ~/ 2)).toDouble(),
            item.rectScreen.width,
            item.rectScreen.height);
        canvas.drawImageRect(
            item.image, rect, rect1, Paint()..color = Colors.red);
        textSpan = new TextSpan(
//            text: '${item.rectScreen.left}-${item.rectScreen.top}',
            text: '${item.index}',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold));
        textPainter =
            new TextPainter(text: textSpan, textDirection: TextDirection.ltr);
        textPainter.layout(minWidth: 40, maxWidth: 80);
        textPainter.paint(
            canvas, Offset(item.rectScreen.left, item.rectScreen.top));
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return reDraw;
  }
}
