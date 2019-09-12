import 'dart:ui';
import 'dart:ui' as ui show Image, Codec, instantiateImageCodec;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:puzzle/bloc/game_bloc.dart';
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
  double gameActiveHeightOrg;
  double paddingX, paddingY, paddingYExt;
  Rect rectEmpty;
  Rect rectTemp;
  GameState gameState;
  int selectedIndex;
  PuzzleTile selectedPuzzle;
  PuzzleTile puzzleEmpty;
  double newX;
  double newY;
  int indexOnScreen;
  Offset offsetTopLeft;
  Offset offsetBottomRight;
  Offset offsetMainLeft;

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
    rectEmpty = Rect.fromLTWH(
        paddingX, paddingYExt, imageScreenWidth, imageScreenHeight);
    offsetTopLeft = rectEmpty.topLeft;
    offsetBottomRight = Offset(size.width - paddingX, size.height - paddingX);
    puzzleEmpty = new PuzzleTile();
    puzzleEmpty.rectScreen = rectEmpty;
    rectTemp = rectEmpty;
    paddingY = paddingYExt + imageScreenHeight;
    offsetMainLeft = Offset(paddingX, paddingY);
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
  double minY,minX,maxX,maxY;

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
                        puzzleTileExt: widget.puzzleEmpty,
                        gameLevelWidth: widget.gameLevelWidth,
                        rectTemp: widget.rectTemp,
                        gameState: widget.gameState,
                        paddingYExt: widget.paddingYExt)
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
//    widget.bloc.reDrawAdd(true);
    RenderBox referenceBox = context.findRenderObject();
    Offset localPosition = referenceBox.globalToLocal(details.globalPosition);
    currentItemX = localPosition.dx;
    currentItemY = localPosition.dy;
    if (isSelectedExtPuzzle(currentItemX, currentItemY, widget.puzzles)) {
      print('selected empty puzzle onPanDown');
      return;
    }
    widget.selectedPuzzle = getSelectedPuzzle(currentItemX, currentItemY);
    widget.indexOnScreen = getActualIndexOnScreen(currentItemX, currentItemY);
    direction = defectDirection(currentItemX, currentItemY);

    print('direction --- ${direction}');

//    print('widget.selectedPuzzle.index --- ${widget.selectedPuzzle.index}');
//    print('widget.indexOnScreen----${widget.indexOnScreen}');
  }

  List xs = [];
  List ys = [];

  void onPanUpdate(DragUpdateDetails details) {
//    widget.bloc.reDrawAdd(true);
//    if (isSelectedExtPuzzle(currentItemX, currentItemY, widget.puzzles)) {
//      print('selected empty puzzle onPanUpdate');
//      return;
//    }
    widget.gameState = GameState.playing;
    RenderBox referenceBox = context.findRenderObject();
    Offset localPosition = referenceBox.globalToLocal(details.globalPosition);
    widget.newX = localPosition.dx;
    widget.newY = localPosition.dy;
    xs.add(widget.newX);
    ys.add(widget.newY);

    int velocity = 5;
    if (direction == Direction.top) {
      PuzzleTile newPuzzle = widget.selectedPuzzle;
      newPuzzle.rectScreen = Rect.fromLTWH(
          widget.selectedPuzzle.rectScreen.left,
          widget.newY,
          widget.selectedPuzzle.rectScreen.width,
          widget.selectedPuzzle.rectScreen.height);
      print('----${newPuzzle.rectScreen}');
      widget.puzzles.replaceRange(
          widget.indexOnScreen, widget.indexOnScreen + 1, [newPuzzle]);
      widget.bloc.reDrawAdd(true);
    } else if (direction == Direction.bottom) {
      PuzzleTile newPuzzle = widget.selectedPuzzle;
      newPuzzle.rectScreen = Rect.fromLTWH(
          widget.selectedPuzzle.rectScreen.left,
          widget.selectedPuzzle.rectScreen.top + velocity,
          widget.selectedPuzzle.rectScreen.width,
          widget.selectedPuzzle.rectScreen.height);
      print('----${newPuzzle.rectScreen}');
      widget.puzzles.replaceRange(
          widget.indexOnScreen, widget.indexOnScreen + 1, [newPuzzle]);
      widget.bloc.reDrawAdd(true);
    } else if (direction == Direction.left) {
      PuzzleTile newPuzzle = widget.selectedPuzzle;
      newPuzzle.rectScreen = Rect.fromLTWH(
          widget.selectedPuzzle.rectScreen.left - velocity,
          widget.selectedPuzzle.rectScreen.top,
          widget.selectedPuzzle.rectScreen.width,
          widget.selectedPuzzle.rectScreen.height);
      print('----${newPuzzle.rectScreen}');
      widget.puzzles.replaceRange(
          widget.indexOnScreen, widget.indexOnScreen + 1, [newPuzzle]);
      widget.bloc.reDrawAdd(true);
    } else if (direction == Direction.right) {
      PuzzleTile newPuzzle = widget.selectedPuzzle;
      newPuzzle.rectScreen = Rect.fromLTWH(
          widget.selectedPuzzle.rectScreen.left + velocity,
          widget.selectedPuzzle.rectScreen.top,
          widget.selectedPuzzle.rectScreen.width,
          widget.selectedPuzzle.rectScreen.height);
      print('----${newPuzzle.rectScreen}');
      widget.puzzles.replaceRange(
          widget.indexOnScreen, widget.indexOnScreen + 1, [newPuzzle]);
      widget.bloc.reDrawAdd(true);
    }
  }

  void onPanEnd(DragEndDetails details) {
//    if (isSelectedExtPuzzle(currentItemX, currentItemY, widget.puzzles)) {
//      print('selected empty puzzle onPanEnd');
//      return;
//    }
//    details = DragEndDetails(velocity: Velocity(pixelsPerSecond: Offset(0, 0)), primaryVelocity: 300.0);
    if (direction == Direction.top) {
      widget.puzzleEmpty = widget.selectedPuzzle;
      widget.puzzles.replaceRange(
          widget.selectedPuzzle.index, widget.selectedPuzzle.index + 1, [
        PuzzleTile()
          ..isEmpty = true
          ..rectEmpty = widget.selectedPuzzle.rectScreen
      ]);
    }
//    widget.bloc.reDrawAdd(true);

//    widget.puzzles.remove(value)
  }

  Direction defectDirection(double currentItemX, double currentItemY) {
    int currentIndexX =
        ((currentItemX - widget.paddingX) / widget.imageScreenWidth).floor();
    var temp = (currentItemY - widget.paddingYExt) / widget.imageScreenHeight;
    int currentIndexY = (temp).floor();

    int emptyIndexX = ((widget.puzzleEmpty.rectScreen.left - widget.paddingX) /
            widget.imageScreenWidth)
        .floor();
    int emptyIndexY =
        ((widget.puzzleEmpty.rectScreen.top - widget.paddingYExt) /
                widget.imageScreenHeight)
            .floor();

    if (currentIndexX == emptyIndexX) {
      if (emptyIndexY > currentIndexY) {
        return Direction.bottom;
      } else if (emptyIndexY < currentIndexY) {
        return Direction.top;
      }
    } else if (currentIndexY == emptyIndexY) {
      if (emptyIndexX > currentIndexX) {
        return Direction.right;
      } else if (emptyIndexX < currentIndexX) {
        return Direction.left;
      }
    }
    return Direction.none;
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

  bool moveToPuzzleExt(double newX, double newY) {
    if (newX > widget.puzzleEmpty.rectScreen.left &&
        newX < widget.puzzleEmpty.rectScreen.right &&
        newY > widget.puzzleEmpty.rectScreen.top &&
        newY < widget.puzzleEmpty.rectScreen.bottom) {
      return true;
    }
    return false;
  }

  PuzzleTile getSelectedPuzzle(double currentItemX, double currentItemY) {
    PuzzleTile result;
    try {
      result = widget.puzzles.firstWhere(
          (item) => (item.rectPaint.left < currentItemX &&
              item.rectPaint.right > currentItemX &&
              item.rectPaint.top < currentItemY &&
              item.rectPaint.bottom > currentItemY),
          orElse: () => null);
    } catch (e) {
      print(e);
    }
    return result;
  }

  int getActualIndexOnScreen(double currentItemX, double currentItemY) {
    var result = ((currentItemX - widget.paddingX) ~/ widget.imageScreenWidth) +
        ((currentItemY - widget.paddingYExt - widget.imageScreenHeight) ~/
            widget.imageScreenHeight);
    return result;
  }
}
