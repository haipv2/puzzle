import 'dart:async';

import 'package:flutter/material.dart';

import 'widget/puzzle_widget.dart';

class GamePage extends StatefulWidget {
  final Image image;
  final int rows = 3;
  final int cols = 3;

  GamePage(this.image);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<Widget> pieces = [];

  //formulate image's size
  Future<Size> getImageSize(Image image) async {
    final Completer<Size> completer = Completer<Size>();

    image.image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(Size(
        info.image.width.toDouble(),
        info.image.height.toDouble(),
      ));
    }));

    final Size imageSize = await completer.future;

    return imageSize;
  }

  void splitImage(Image image) async {
    Size imageSize = await getImageSize(image);

    for (int x = 0; x < widget.rows; x++) {
      for (int y = 0; y < widget.cols; y++) {
        setState(() {
          pieces.add(PuzzlePiece(
              key: GlobalKey(),
              image: image,
              imageSize: imageSize,
              row: x,
              col: y,
              maxRow: widget.rows,
              maxCol: widget.cols));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Stack(
          children: pieces,
        ),
      ),
    );
  }
}
