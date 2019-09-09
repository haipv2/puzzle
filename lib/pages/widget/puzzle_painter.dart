import 'dart:ui';
import 'dart:ui' as ui show Image;

import 'package:flutter/material.dart';
import 'package:puzzle/model/puzzle_tile.dart';

class PuzzlePainter extends CustomPainter {
  final double paddingX, paddingY;
  final List<PuzzleTile> puzzles;
  TextSpan textSpan;
  TextPainter textPainter;
  Rect rectExt;
  bool reDraw;
  PuzzlePainter({this.paddingX, this.paddingY, this.puzzles, this.rectExt}) {
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(rectExt, Paint()..color = Colors.white);
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
    }

    for (int i = 0; i < puzzles.length; i++) {
      PuzzleTile item = puzzles[i];
      textSpan = new TextSpan(
          text: '${item.index}',
          style: TextStyle(color: Colors.red, fontSize: 20));
      textPainter =
          new TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout(minWidth: 50, maxWidth: 80);
      Rect rect1 = Rect.fromLTWH(
          (paddingX + item.rectScreen.width * (i % 2)).toDouble(),
          (paddingY + item.rectScreen.height * (i ~/ 2)).toDouble(),
          item.rectScreen.width,
          item.rectScreen.height);
      textPainter.paint(canvas, rect1.topLeft);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return reDraw;
  }
}
