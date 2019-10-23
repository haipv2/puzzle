import 'dart:ui' as ui show Image;

import 'package:flutter/material.dart';
import 'package:puzzle/bloc/global_bloc.dart';
import 'package:puzzle/commons/app_style.dart';
import 'package:puzzle/commons/enums.dart';
import 'package:puzzle/model/puzzle_tile.dart';
import 'dart:math' as math;

class PuzzlePainter extends CustomPainter {
  final double paddingX, paddingY, paddingYExt;
  final List<PuzzleTile> puzzles;
  TextSpan textSpanIdx;
  TextSpan textSpanMove;
  TextSpan textSpanTime;
  TextSpan textSpanHelp;
  TextPainter textPainter;
  PuzzleTile puzzleTileEmpty;
  Rect rectTemp;
  bool reDraw;
  int gameLevelWidth, gameLevelHeight;
  GameState gameState;
  ui.Image orgImage, tipsImage;
  double imageScreenWidth, imageScreenHeight;
  int move, second;
  double gameActiveWidth;
  String timeStr;
  bool showHelp, isDone;
  Offset offsetMove;
  Rect rectTextMove;
  Rect rectHelp;

  PuzzlePainter(
      {this.paddingX,
      this.paddingY,
      this.puzzles,
      this.puzzleTileEmpty,
      this.gameLevelWidth,
      this.gameLevelHeight,
      this.rectTemp,
      this.gameState,
      this.paddingYExt,
      this.offsetMove,
      this.orgImage,
      this.tipsImage,
      this.imageScreenWidth,
      this.gameActiveWidth,
      this.imageScreenHeight});

  @override
  void paint(Canvas canvas, Size size) {
    //paint original pic
    var orgImgX = paddingX + (gameLevelWidth - 1) * imageScreenWidth;
    canvas.drawImageRect(
        orgImage,
        Rect.fromLTWH(
            0, 0, orgImage.width.toDouble(), orgImage.height.toDouble()),
        Rect.fromLTWH(orgImgX + imageScreenWidth / 4, paddingYExt,
            imageScreenWidth * .75, imageScreenHeight * .75),
        Paint());

    // paint image
    if (puzzleTileEmpty.image == null) {
      canvas.drawRect(puzzleTileEmpty.rectPaint, Paint()..color = Colors.white);
    }

    if (puzzles != null) {
      for (int i = 0; i < puzzles.length; i++) {
        PuzzleTile item = puzzles[i];
        if (item.isEmpty) {
          canvas.drawRect(item.rectPaint, Paint()..color = colorApp);
          continue;
        }
        Rect rect = Rect.fromLTWH(
            0, 0, item.image.width.toDouble(), item.image.height.toDouble());
        Rect rect1;
        if (gameState == GameState.playing) {
          rect1 = Rect.fromLTWH(item.rectPaint.left, item.rectPaint.top,
              item.rectPaint.width, item.rectPaint.height);
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
        canvas.drawImageRect(item.image, rect, rect1, Paint());
      }

      // paint text
      if (showHelp) {
        for (int i = 0; i < puzzles.length; i++) {
          PuzzleTile item = puzzles[i];
          if (item.isEmpty) {
            continue;
          }
          textSpanIdx = new TextSpan(
              text: '${item.index}',
              style: TextStyle(color: Colors.red, fontSize: 20));
          textPainter = new TextPainter(
              text: textSpanIdx, textDirection: TextDirection.ltr);
          textPainter.layout(minWidth: 50, maxWidth: 80);
          Rect rect1 = item.rectPaint;
          textPainter.paint(canvas, rect1.topLeft);
        }
      }

      // show move
      globalBloc.text('txtMove');
      textSpanMove = new TextSpan(text: 'Move: ${move}', style: commonStyleM);
      textPainter =
          new TextPainter(text: textSpanMove, textDirection: TextDirection.ltr);
      textPainter.layout(minWidth: 50, maxWidth: gameActiveWidth / 2);
      textPainter.paint(canvas, rectTextMove.topLeft);
    }

    //draw tips image
    if (tipsImage != null)
      canvas.drawImageRect(
          tipsImage,
          Rect.fromLTWH(
              0, 0, tipsImage.width.toDouble(), tipsImage.height.toDouble()),
          rectHelp,
          Paint());
  }

  // Time formatting, converted to the corresponding hh:mm:ss format according to the total number of seconds
  String constructTime(int seconds) {
    int hour = seconds ~/ 3600;
    int minute = seconds % 3600 ~/ 60;
    int second = seconds % 60;
    return formatTime(hour) +
        ":" +
        formatTime(minute) +
        ":" +
        formatTime(second);
  }

  // Digital formatting, converting 0-9 time to 00-09
  String formatTime(int timeNum) {
    return timeNum < 10 ? "0" + timeNum.toString() : timeNum.toString();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return reDraw;
  }
}
