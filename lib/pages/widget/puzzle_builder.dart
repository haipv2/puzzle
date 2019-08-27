import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui show instantiateImageCodec, Codec, Image;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:puzzle/model/puzzle_tile.dart';

class PuzzleBuilder {
  ui.Image image;
  double eachWidth;
  double eachHeight;
  Size screenSize;
  double baseX;
  double baseY;

  int levelWidth;
  int levelHeight;
  double eachBitmapWidth;
  double eachBitmapHeight;
  double paddingHorizontal = 0.0;
  Rect extRect;

  Future<ui.Image> init(
      String path, Size size, int levelWidth, int levelHeight) async {
    await getImage(path);

    screenSize = size;
    this.levelWidth = levelWidth;
    this.levelHeight = levelHeight;

//    eachWidth = screenSize.width * 0.8 / levelWidth;
    paddingHorizontal = screenSize.width * 0.05;
    eachWidth = screenSize.width * 0.9 / levelWidth;
    eachHeight =
        (screenSize.height * 0.9 - paddingHorizontal) / (levelHeight + 1);
    eachBitmapWidth = (image.width / levelWidth);
    eachBitmapHeight = (image.height / levelHeight);
    baseX = screenSize.width * 0.05;
    baseY = eachHeight + paddingHorizontal * 2;
    extRect =
        Rect.fromLTWH(baseX, paddingHorizontal * 2, eachWidth, eachHeight);
    return image;
  }

  Future<ui.Image> getImage(String path) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    FrameInfo frameInfo = await codec.getNextFrame();
    image = frameInfo.image;
    return image;
  }

  List<PuzzleTile> splitImage() {
    List<PuzzleTile> list = [];
    PuzzleTile node = PuzzleTile();

    for (int j = 0; j < levelWidth; j++) {
      for (int i = 0; i < levelHeight; i++) {
        node = PuzzleTile();
        node.rect = buildImgRect(i, j);
        node.index = j * levelWidth + i;
        makeBitmap(node);
        list.add(node);
      }
    }
    return list;
  }

  Rect buildImgRect(int i, int j) {
    return Rect.fromLTWH(
        baseX + eachWidth * i, baseY + eachHeight * j, eachWidth, eachHeight);
  }

  void makeBitmap(PuzzleTile node) async {
    int width = node.getXIndex(levelWidth);
    int height = node.getYIndex(levelHeight);

    Rect rect = getShapeRect(width, height, eachBitmapWidth, eachBitmapHeight);
    rect = rect.shift(Offset(eachBitmapWidth.toDouble() * width,
        eachBitmapHeight.toDouble() * height));

    PictureRecorder recorder = PictureRecorder();
    double ww = eachBitmapWidth.toDouble();
    double wh = eachBitmapHeight.toDouble();
    Canvas canvas = Canvas(recorder, Rect.fromLTWH(0.0, 0.0, ww, wh));

    Rect rectDest = Rect.fromLTRB(0.0, 0.0, rect.width, rect.height);

    Paint paint = Paint();
    canvas.drawImageRect(image, rect, rectDest, paint);
    node.image = await recorder.endRecording().toImage(ww.floor(), wh.floor());
//    node.rect = buildImgRect(width, height);
  }

  Rect getShapeRect(int i, int j, double width, double height) {
    return Rect.fromLTRB(0.0, 0.0, width, height);
  }

}
