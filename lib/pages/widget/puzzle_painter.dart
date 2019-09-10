import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:puzzle/bloc/game_state.dart';
import 'package:puzzle/model/puzzle_tile.dart';

class PuzzlePainter extends CustomPainter {
  final double paddingX, paddingY;
  final List<PuzzleTile> puzzles;
  TextSpan textSpan;
  TextPainter textPainter;
  PuzzleTile puzzleTileExt;
  Rect rectTemp;
  bool reDraw;
  int gameLevelWidth;
  GameState gameState;

  PuzzlePainter(
      {this.paddingX,
      this.paddingY,
      this.puzzles,
      this.puzzleTileExt,
      this.gameLevelWidth,
      this.rectTemp,
      this.gameState});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(puzzleTileExt.rectScreen, Paint()..color = Colors.white);
    if (puzzles != null) {
      for (int i = 0; i < puzzles.length; i++) {
        PuzzleTile item = puzzles[i];
        if (item.isEmpty) {
          canvas.drawRect(item.rectEmpty, Paint()..color = Colors.white);
          continue;
        }
        Rect rect = Rect.fromLTWH(
            0, 0, item.image.width.toDouble(), item.image.height.toDouble());
        Rect rect1 = Rect.fromLTWH(
            (paddingX + item.rectScreen.width * (i % gameLevelWidth))
                .toDouble(),
            (paddingY + item.rectScreen.height * (i ~/ gameLevelWidth))
                .toDouble(),
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
            (paddingX + item.rectScreen.width * (i % gameLevelWidth))
                .toDouble(),
            (paddingY + item.rectScreen.height * (i ~/ gameLevelWidth))
                .toDouble(),
            item.rectScreen.width,
            item.rectScreen.height);
        textPainter.paint(canvas, rect1.topLeft);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    print('reDraw --- ${reDraw}');
    return reDraw;
  }
}
