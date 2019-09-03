import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:puzzle/bloc/bloc_provider.dart';
import 'package:puzzle/bloc/bloc_widget/bloc_state_builder.dart';
import 'package:puzzle/bloc/game_bloc.dart';
import 'package:puzzle/bloc/game_event.dart';
import 'package:puzzle/bloc/game_state.dart';
import 'package:puzzle/model/puzzle_tile.dart';
import 'dart:ui' as ui show Image, Codec, instantiateImageCodec;
import 'pending_page.dart';
import 'widget/puzzle_painter.dart';

class PuzzleGame extends StatefulWidget {
  final String imgPath;
  final Size size;
  ui.Image image;
  List<PuzzleTile> puzzles;
  double screenSize;
  int imageSizeWidth;
  int imageSizeHeight;
  int gameLevelWidth;
  int gameLevelHeight;
  double imageScreenWidth;
  double imageScreenHeight;
  double imageEachWidth;
  double imageEachHeight;
  double gameActiveWidth;
  double gameActiveHeight;
  double paddingX, paddingY;

  PuzzleGame(this.imgPath, this.size, this.gameLevelWidth,this.gameLevelHeight) {
    paddingX = paddingY = size.width * 0.05;
    gameActiveWidth = size.width * 0.9;
    gameActiveHeight = size.height - paddingY * 2;

    init(imgPath).then((image) {
      imageSizeWidth = image.width;
      imageSizeHeight = image.height;
      imageScreenWidth = gameActiveWidth / gameLevelWidth;
      imageScreenHeight = gameActiveHeight / gameLevelHeight;
      imageEachHeight = image.height / gameLevelHeight;
      imageEachWidth = image.width / gameLevelWidth;
      puzzles = buildPuzzles();
    });
  }

  @override
  _PuzzleGameState createState() => _PuzzleGameState();

  Future<ui.Image> init(String imgPath) async {
    image = await getImage(imgPath);
    print(image);
    return image;
  }

  Future<ui.Image> getImage(String path) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    FrameInfo frameInfo = await codec.getNextFrame();
    image = frameInfo.image;
    return image;
  }

  List<PuzzleTile> buildPuzzles() {
    List<PuzzleTile> result = [];
    result.add(PuzzleTile()
      ..image = image
      ..offset = Offset(paddingX, paddingY));
    return result;
  }
}

class _PuzzleGameState extends State<PuzzleGame> {
  GameBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<GameBloc>(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('game_page');
    return StreamBuilder<Image>(
        stream: bloc.image,
        builder: (context, snapshot) {
          return GestureDetector(
            child: CustomPaint(
              painter: PuzzlePainter(
                  x: widget.paddingX,
                  y: widget.paddingY,
                  puzzles: widget.puzzles),
            ),
          );
        });
  }
}
