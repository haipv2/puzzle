import 'dart:ui';
import 'dart:ui' as ui show Image, Codec, instantiateImageCodec;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:puzzle/bloc/game_bloc.dart';
import 'package:puzzle/bloc/game_state.dart';
import 'package:puzzle/commons/enums.dart';
import 'package:puzzle/model/puzzle_tile.dart';

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
  double paddingX, paddingY, paddingYExt;
  Rect rectExt;
  Rect rectTemp;
  GameState gameState;
  int selectedIndex;
  PuzzleTile selectedPuzzle;
  PuzzleTile puzzleExt;
  double newX;
  double newY;

  GameBloc bloc;

  PuzzleGame(this.imgPath, this.size, this.gameLevelWidth, this.gameLevelHeight,
      GameBloc bloc) {
    this.bloc = bloc;
    paddingX = paddingY = size.width * 0.05;
    gameActiveWidth = size.width * 0.9;
    gameActiveHeight = size.height - paddingY * 4;

    init(imgPath);
  }

  @override
  _PuzzleGameState createState() => _PuzzleGameState();

  Future<ui.Image> init(String imgPath) async {
    image = await getImage(imgPath);
    imageSizeWidth = image.width;
    imageSizeHeight = image.height;
    imageScreenWidth = gameActiveWidth / gameLevelWidth;
    imageScreenHeight = gameActiveHeight / gameLevelHeight;

    gameActiveHeight = gameActiveHeight - imageScreenHeight;
    imageScreenHeight = gameActiveHeight / gameLevelHeight;
    paddingYExt = paddingY * 3;
    rectExt = Rect.fromLTWH(
        paddingX, paddingYExt, imageScreenWidth, imageScreenHeight);
    puzzleExt = new PuzzleTile();
    puzzleExt.rectScreen = rectExt;
    rectTemp = rectExt;
    paddingY = paddingYExt + imageScreenHeight;
    imageEachHeight = image.height / gameLevelHeight;
    imageEachWidth = image.width / gameLevelWidth;

    await setPuzzles();
    bloc.puzzlesAdd(puzzles);
    return image;
  }

  Future<List<PuzzleTile>> buildPuzzles() async {
    List<PuzzleTile> result = [];
//    result.add(PuzzleTile()
//      ..isEmpty = true
//      ..rectScreen = rectExt
//      ..image = null
//      ..index = 0);
    for (int i = 0; i < gameLevelHeight; i++) {
      for (int j = 0; j < gameLevelWidth; j++) {
        Rect rectScreen = Rect.fromLTWH(
            paddingX + j * imageScreenWidth,
            paddingY + i * imageScreenHeight,
            imageScreenWidth * 0.996,
            imageScreenHeight * 0.996);

        PictureRecorder pictureRecorder = PictureRecorder();
        Canvas canvas = Canvas(pictureRecorder,
            Rect.fromLTWH(0, 0, imageEachWidth, imageEachHeight));

        Rect rect3 = Rect.fromLTWH(j * imageEachWidth, i * imageEachHeight,
            imageEachWidth, imageEachHeight);
        Rect rect4 = Rect.fromLTWH(0, 0, rect3.width, rect3.height);
        var imageIndex = i * gameLevelWidth + j;

        canvas.drawImageRect(image, rect3, rect4, Paint());
        ui.Image imageExtract = await pictureRecorder
            .endRecording()
            .toImage(imageEachWidth.floor(), imageEachHeight.floor());
        result.add(PuzzleTile()
          ..isEmpty = false
          ..index = imageIndex
          ..image = imageExtract
//          ..rectImage = Rect.fromLTWH(0,0,image.width.toDouble(),image.height.toDouble())
          ..rectScreen = rectScreen);
      }
    }
//    result.shuffle();
    return result;
  }

  Future<List<PuzzleTile>> setPuzzles() async {
    puzzles = await buildPuzzles();
    return puzzles;
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
  Direction direction;
  double currentItemX;
  double currentItemY;
  double newItemX;
  double newItemY;

  @override
  void initState() {
    super.initState();
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
          return StreamBuilder<bool>(
              stream: widget.bloc.reDraw,
              builder: (context, snapshot) {
                return GestureDetector(
                  child: CustomPaint(
                    painter: PuzzlePainter(
                        paddingX: widget.paddingX,
                        paddingY: widget.paddingY,
                        puzzles: widget.puzzles,
                        puzzleTileExt: widget.puzzleExt,
                        gameLevelWidth: widget.gameLevelWidth,
                        rectTemp: widget.rectTemp,
                        gameState: widget.gameState)
                      ..reDraw = snapshot.data ?? false,
                  ),
                  onPanDown: onPanDown,
                  onPanUpdate: onPanUpdate,
                  onPanEnd: onPanEnd,
                );
              });
        });
  }

  void onPanDown(DragDownDetails details) {
    widget.bloc.reDrawAdd(true);
    RenderBox referenceBox = context.findRenderObject();
    Offset localPosition = referenceBox.globalToLocal(details.globalPosition);
    currentItemX = localPosition.dx;
    currentItemY = localPosition.dy;
    if (isSelectedExtPuzzle(currentItemX, currentItemY, widget.puzzles)) {
      print('selected empty puzzle onPanDown');
      return;
    }
    widget.selectedPuzzle = getSelectedPuzzle(currentItemX, currentItemY);
    print('${widget.selectedPuzzle.index}');

  }

  void onPanUpdate(DragUpdateDetails details) {
    if (isSelectedExtPuzzle(currentItemX, currentItemY, widget.puzzles)) {
      print('selected empty puzzle onPanUpdate');
      return;
    }
    RenderBox referenceBox = context.findRenderObject();
    Offset localPosition = referenceBox.globalToLocal(details.globalPosition);
    widget.newX = localPosition.dx;
    widget.newY = localPosition.dy;
//    direction = defectDirection(
//        currentItemX, currentItemY, newX, newY);
    widget.bloc.reDrawAdd(true);

  }

  void onPanEnd(DragEndDetails details) {
    if (isSelectedExtPuzzle(currentItemX, currentItemY, widget.puzzles)) {
      print('selected empty puzzle onPanEnd');
      return;
    }
    widget.bloc.reDrawAdd(false);

//    widget.puzzles.remove(value)
  }

  Direction defectDirection(
      double currentItemX, double currentItemY, double newX, double newY) {
    if (widget.rectTemp.left < currentItemX) {
      return Direction.left;
    } else if (widget.rectTemp.left > currentItemX) {
      return Direction.right;
    } else if (widget.rectTemp.top < currentItemY) {
      return Direction.top;
    } else if (widget.rectTemp.top > currentItemY) {
      return Direction.bottom;
    } else {
      return Direction.none;
    }
  }

  bool isSelectedExtPuzzle(
      double currentItemX, double currentItemY, List<PuzzleTile> puzzles) {
    if (currentItemX > widget.paddingX &&
        currentItemX < widget.rectTemp.right &&
        currentItemY > widget.paddingYExt &&
        currentItemY < widget.rectTemp.bottom) {
      return true;
    }
    return false;
  }

  bool moveToPuzzleExt(double newX,double newY){
    if (newX > widget.puzzleExt.rectScreen.left &&
        newX < widget.puzzleExt.rectScreen.right &&
        newY > widget.puzzleExt.rectScreen.top &&
        newY < widget.puzzleExt.rectScreen.bottom) {
      return true;
    }
    return false;
  }

  PuzzleTile getSelectedPuzzle(double currentItemX, double currentItemY) {
    PuzzleTile result = widget.puzzles.firstWhere((item) =>
        (item.rectScreen.left < currentItemX &&
            item.rectScreen.right > currentItemX &&
            item.rectScreen.top < currentItemY &&
            item.rectScreen.bottom > currentItemY));
    return result;
  }
}
