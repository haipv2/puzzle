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
  int coutner = 0;

  GameBloc bloc;

  PuzzleGame(
      this.imgPath, this.size, this.gameLevelWidth, this.gameLevelHeight) {
    paddingX = paddingY = size.width * 0.05;
    gameActiveWidth = size.width * 0.9;
    gameActiveHeight = size.height - paddingY * 2;

    init(imgPath).then((image) {
      print('loaded image');
//      setPuzzles();
    });
  }

  @override
  _PuzzleGameState createState() => _PuzzleGameState();

  Future<ui.Image> init(String imgPath) async {
    image = await getImage(imgPath);
    imageSizeWidth = image.width;
    imageSizeHeight = image.height;
    imageScreenWidth = gameActiveWidth / gameLevelWidth;
    imageScreenHeight = gameActiveHeight / gameLevelHeight;
    imageEachHeight = image.height / gameLevelHeight;
    imageEachWidth = image.width / gameLevelWidth;
    await setPuzzles();
    bloc.puzzlesAdd(puzzles);
    return image;
  }

  Future<List<PuzzleTile>> buildPuzzles() async {
    List<PuzzleTile> result = [];
    for (int i = 0; i < gameLevelHeight; i++) {
      for (int j = 0; j < gameLevelWidth; j++) {
        coutner++;
        Rect rectImage = Rect.fromLTWH(j * imageEachWidth, i * imageEachHeight,
            imageEachWidth, imageEachHeight);
        Rect rectScreen = Rect.fromLTWH(
            paddingX + j * imageScreenWidth,
            paddingY + i * imageScreenHeight,
            imageScreenWidth * 0.996,
            imageScreenHeight * 0.996);

        PictureRecorder pictureRecorder = PictureRecorder();
        Canvas canvas = Canvas(
            pictureRecorder,
            Rect.fromLTWH(
                0,
                0,
                imageEachWidth,
                imageEachHeight));


        Rect rect1 = Rect.fromLTWH(imageEachWidth*j, imageEachHeight*i,
            image.width.toDouble(), image.height.toDouble());
        Rect rect2= Rect.fromLTWH(paddingX + j * imageScreenWidth,
            paddingY + i * imageScreenHeight,
            rect1.width, rect1.height);

        canvas.drawImageRect(image, rect1, rect2, Paint());
        ui.Image imageExtract = await pictureRecorder
            .endRecording()
            .toImage(imageEachWidth.floor(), imageEachHeight.floor());
        result.add(PuzzleTile()
          ..index = coutner
          ..image = imageExtract
          ..rectImage = rectImage
          ..rectScreen = rectScreen);
      }
    }

    return result;
  }

  Future<void> setPuzzles() async {
    print('Begin setPuzzle');
    puzzles = await buildPuzzles();
    print('End setPuzzle');
  }

  Future<ui.Image> getImage(String path) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    FrameInfo frameInfo = await codec.getNextFrame();
    image = frameInfo.image;
    return image;
  }
}

class _PuzzleGameState extends State<PuzzleGame> {
  @override
  void initState() {
    super.initState();
    widget.bloc = BlocProvider.of<GameBloc>(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('game_page');
    return StreamBuilder<List<PuzzleTile>>(
        stream: widget.bloc.puzzles,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return PendingPage();
          }
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
