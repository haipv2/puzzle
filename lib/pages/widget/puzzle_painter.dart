import 'dart:ui';
import 'dart:ui' as ui show Image;

import 'package:flutter/material.dart';
import 'package:puzzle/model/puzzle_tile.dart';

class PuzzlePainter extends CustomPainter {
  final double x,y;
  final List<PuzzleTile> puzzles;

  PuzzlePainter({this.x, this.y,this.puzzles});

  @override
  void paint(Canvas canvas, Size size) {
    puzzles.forEach((item){
      Rect srcRect = Rect.fromLTWH(0, 0, 100, 100);
      Rect destRect = Rect.fromLTWH(0, 0, 200, 200);
      canvas.drawImageRect(item.image, srcRect, destRect, Paint());
    });


  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
