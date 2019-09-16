import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:puzzle/commons/enums.dart';
import 'package:puzzle/model/puzzle_tile.dart';

class PuzzlePainter extends CustomPainter {
  final double paddingX, paddingY, paddingYExt;
  final List<PuzzleTile> puzzles;
  TextSpan textSpan;
  TextPainter textPainter;
  PuzzleTile puzzleTileEmpty;
  Rect rectTemp;
  bool reDraw;
  int gameLevelWidth;
  GameState gameState;

  PuzzlePainter(
      {this.paddingX,
      this.paddingY,
      this.puzzles,
      this.puzzleTileEmpty,
      this.gameLevelWidth,
      this.rectTemp,
      this.gameState,
      this.paddingYExt});

  @override
  void paint(Canvas canvas, Size size) {
    if (puzzleTileEmpty.image == null) {
      canvas.drawRect(puzzleTileEmpty.rectPaint, Paint()..color = Colors.white);
    } else {
      Rect rect = Rect.fromLTWH(0, 0, puzzleTileEmpty.image.width.toDouble(),
          puzzleTileEmpty.image.height.toDouble());
      Rect rect1 = Rect.fromLTWH(paddingX, paddingYExt,
          puzzleTileEmpty.rectScreen.width, puzzleTileEmpty.rectScreen.height);
      canvas.drawImageRect(puzzleTileEmpty.image, rect, rect1, Paint());
      textSpan = new TextSpan(
          text: '${puzzleTileEmpty.index}',
          style: TextStyle(color: Colors.red, fontSize: 20));
      textPainter =
          new TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout(minWidth: 50, maxWidth: 80);
      textPainter.paint(canvas, rect1.topLeft);
    }
    if (puzzles != null) {
      for (int i = 0; i < puzzles.length; i++) {
        PuzzleTile item = puzzles[i];
        if (item.isEmpty) {
          canvas.drawRect(item.rectPaint, Paint()..color = Colors.white);
          continue;
        }
        Rect rect = Rect.fromLTWH(
            0, 0, item.image.width.toDouble(), item.image.height.toDouble());
        Rect rect1;
        if (gameState == GameState.playing) {
          rect1 = Rect.fromLTWH(item.rectScreen.left, item.rectScreen.top,
              item.rectScreen.width, item.rectScreen.height);
        } else {
          rect1 = Rect.fromLTWH(
              (paddingX + item.rectScreen.width * (i % gameLevelWidth))
                  .toDouble(),
              (paddingY + item.rectScreen.height * (i ~/ gameLevelWidth))
                  .toDouble(),
              item.rectScreen.width,
              item.rectScreen.height);
        }
        item.rectPaint = rect1;
        canvas.drawImageRect(
            item.image, rect, rect1, Paint()..color = Colors.red);
      }

      for (int i = 0; i < puzzles.length; i++) {
        PuzzleTile item = puzzles[i];
        if (item.isEmpty) {
          continue;
        }
        textSpan = new TextSpan(
            text: '${item.index}',
            style: TextStyle(color: Colors.red, fontSize: 20));
        textPainter =
            new TextPainter(text: textSpan, textDirection: TextDirection.ltr);
        textPainter.layout(minWidth: 50, maxWidth: 80);
//        Rect rect1 = Rect.fromLTWH(
//            (paddingX + item.rectScreen.width * (i % gameLevelWidth))
//                .toDouble(),
//            (paddingY + item.rectScreen.height * (i ~/ gameLevelWidth))
//                .toDouble(),
//            item.rectScreen.width,
//            item.rectScreen.height);
        Rect rect1 = item.rectPaint;
        textPainter.paint(canvas, rect1.topLeft);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return reDraw;
  }
}
