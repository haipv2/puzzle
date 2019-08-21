import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui show instantiateImageCodec, Codec, Image;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:puzzle/model/ImageNode.dart';

class PuzzleMagic {
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

  Future<ui.Image> init(
      String path, Size size, int levelWidth, int levelHeight) async {
    await getImage(path);

    screenSize = size;
    this.levelWidth = levelWidth;
    this.levelHeight = levelHeight;

//    eachWidth = screenSize.width * 0.8 / levelWidth;
    double paddingHorizontal = screenSize.width*0.1;
    eachWidth = screenSize.width*0.9/ levelWidth;
    eachHeight = (screenSize.height-screenSize.width*0.1)/(levelHeight+1);
    print('eachWidth--- $eachWidth');
    print('screenSize.width--- ${screenSize.width}');
    baseX = screenSize.width * 0.05;
    baseY = screenSize.height * 0.1 + eachHeight;

    eachBitmapWidth = (image.width / levelWidth);
    eachBitmapHeight = (image.height / levelHeight);
    return image;
  }

  Future<ui.Image> getImage(String path) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    FrameInfo frameInfo = await codec.getNextFrame();
    image = frameInfo.image;
    return image;
  }

  List<ImageNode> doTask() {
    List<ImageNode> list = [];
    for (int j = 0; j < levelWidth; j++) {
      for (int i = 0; i < levelHeight; i++) {
//        if (j * levelWidth + i < levelWidth * levelHeight - 1) {
        ImageNode node = ImageNode();
        node.rect = getOkRectF(i, j);
        node.index = j * levelWidth + i;
        makeBitmap(node);
        list.add(node);
//        }
      }
    }
    return list;
  }

  Rect getOkRectF(int i, int j) {
    return Rect.fromLTWH(
        baseX + eachWidth * i, baseY + eachHeight * j, eachWidth, eachHeight);
  }

  void makeBitmap(ImageNode node) async {
    int i = node.getXIndex(levelWidth);
    int j = node.getYIndex(levelWidth);

    Rect rect = getShapeRect(i, j, eachBitmapWidth);
    rect = rect.shift(
        Offset(eachBitmapWidth.toDouble() * i, eachBitmapWidth.toDouble() * j));

    PictureRecorder recorder = PictureRecorder();
    double ww = eachBitmapWidth.toDouble();
    Canvas canvas = Canvas(recorder, Rect.fromLTWH(0.0, 0.0, ww, ww));

    Rect rect2 = Rect.fromLTRB(0.0, 0.0, rect.width, rect.height);

    Paint paint = Paint();
    canvas.drawImageRect(image, rect, rect2, paint);
    node.image = await recorder.endRecording().toImage(ww.floor(), ww.floor());
    node.rect = getOkRectF(i, j);
  }

  Rect getShapeRect(int i, int j, double width) {
    return Rect.fromLTRB(0.0, 0.0, width, width);
  }
}
