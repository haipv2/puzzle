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
        canvas.drawImageRect(
            item.image, item.rectImage, item.rectScreen, Paint());
        textSpan = new TextSpan(
            text: '${item.index}', style: TextStyle(color: Colors.red));
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
