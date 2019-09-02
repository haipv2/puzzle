import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui show instantiateImageCodec, Codec, Image;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:puzzle/model/puzzle_tile.dart';

class PuzzleBuilder {
  ui.Image image;
  double screenImageWidth;
  double screenImageHeight;
  Size screenSize;
  double baseX;
  double baseY;

  int levelWidth;
  int levelHeight;
  double eachImageWidth;
  double eachImageHeight;
  double paddingWidth = 0.0;
  Rect extRect;

  Future<ui.Image> init(
      String path, Size size, int levelWidth, int levelHeight) async {
    await getImage(path);

    screenSize = size;
    this.levelWidth = levelWidth;
    this.levelHeight = levelHeight;

//    eachWidth = screenSize.width * 0.8 / levelWidth;
    paddingWidth = screenSize.width * 0.05;
    screenImageWidth = screenSize.width * 0.9 / levelWidth;
    screenImageHeight = (screenSize.height - paddingWidth*2) / levelHeight;
    eachImageWidth = (image.width / levelWidth);
    eachImageHeight = (image.height / levelHeight);

    baseX = paddingWidth;
//    baseY = screenImageHeight + paddingWidth * 2;
    baseY = baseX;
    extRect = Rect.fromLTWH(
        baseX, paddingWidth, screenImageWidth, screenImageHeight);
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
    return Rect.fromLTWH(baseX + screenImageWidth * i,
        baseY + screenImageHeight * j, screenImageWidth, screenImageHeight);
  }

  void makeBitmap(PuzzleTile node) async {
    int width = node.getXIndex(levelWidth);
    int height = node.getYIndex(levelHeight);

    Rect rect = getShapeRect(width, height, eachImageWidth, eachImageHeight);
    rect = rect.shift(Offset(eachImageWidth.toDouble() * width,
        eachImageHeight.toDouble() * height));

    PictureRecorder recorder = PictureRecorder();
    double ww = eachImageWidth.toDouble();
    double wh = eachImageHeight.toDouble();
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
