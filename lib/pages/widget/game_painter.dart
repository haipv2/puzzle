import 'dart:ui';
import 'dart:ui' as ui show instantiateImageCodec, Codec, Image, TextStyle;

import 'package:flutter/material.dart';
import 'package:puzzle/model/puzzle_tile.dart';

import '../game_page.dart';

class GamePainter extends CustomPainter {
  Paint mypaint;
  Path path;
  final int level;
  final List<PuzzleTile> nodes;
  final PuzzleTile hitNode;
  final bool needdraw;

  final double downX, downY, newX, newY;
  final List<PuzzleTile> hitNodeList;
  Direction direction;
  Rect extRect;

  GamePainter(
      this.nodes,
      this.level,
      this.hitNode,
      this.hitNodeList,
      this.direction,
      this.downX,
      this.downY,
      this.newX,
      this.newY,
      this.needdraw,
      this.extRect) {
    mypaint = Paint();
    mypaint.style = PaintingStyle.stroke;
    mypaint.strokeWidth = 1.0;
    mypaint.color = Color(0xa0dddddd);

    path = Path();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes != null) {
      Paint paint = Paint();
      paint.color = Colors.white;
      paint.style = PaintingStyle.fill;
      canvas.drawRect(extRect, paint);

      for (int i = 0; i < nodes.length; ++i) {
        PuzzleTile node = nodes[i];
        Rect rectDest = Rect.fromLTRB(
            node.rect.left, node.rect.top, node.rect.right, node.rect.bottom);
        if (hitNodeList != null && hitNodeList.contains(node)) {
          if (direction == Direction.left || direction == Direction.right) {
            rectDest = node.rect.shift(Offset(newX - downX, 0.0));
          } else if (direction == Direction.top ||
              direction == Direction.bottom) {
            rectDest = node.rect.shift(Offset(0.0, newY - downY));
          }
        }
        Rect srcRect = Rect.fromLTRB(0.0, 0.0, node?.image?.width?.toDouble(),
            node?.image?.height?.toDouble());
        canvas.drawImageRect(
            nodes[i].image,
            srcRect,
            rectDest,
            Paint()
              ..style = PaintingStyle.stroke
              ..color = Colors.red..strokeCap=StrokeCap.round);
      }

      for (int i = 0; i < nodes.length; ++i) {
        PuzzleTile node = nodes[i];

        ParagraphBuilder pb = ParagraphBuilder(ParagraphStyle(
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w300,
          fontStyle: FontStyle.normal,
          fontSize: hitNode == node ? 30.0 : 35.0,
        ));

        if (hitNode == node) {
//          pb.pushStyle(ui.TextStyle(color: Color(0xff00ff00)));
          pb.pushStyle(ui.TextStyle(color: Colors.red));
        }
        pb.pushStyle(ui.TextStyle(color: Colors.red));
        pb.addText('${node.index + 1}');
        ParagraphConstraints pc = ParagraphConstraints(width: node.rect.width);
        Paragraph paragraph = pb.build()..layout(pc);

        Offset offset = Offset(node.rect.left,
            node.rect.top + node.rect.height / 2 - paragraph.height / 2);
        if (hitNodeList != null && hitNodeList.contains(node)) {
          if (direction == Direction.left || direction == Direction.right) {
            offset = Offset(offset.dx + newX - downX, offset.dy);
          } else if (direction == Direction.top ||
              direction == Direction.bottom) {
            offset = Offset(offset.dx, offset.dy + newY - downY);
          }
        }
        canvas.drawParagraph(paragraph, offset);
      }
    }
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) {
    var result = this.needdraw || oldDelegate.needdraw;
    return result;
  }
}
