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
  PuzzleTile selectedPuzzle, puzzleTmp;
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
    puzzleEmpty.isEmpty = true;
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
  double selectedItemX;
  double selectedItemY;
  double newItemX;
  double newItemY;
  double minY, minX, maxX, maxY;

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

  double distanceTop;
  double distanceBottom;
  double originTopX, originTopY;
  double selectedTopX, selectedTopY;

  void onPanDown(DragDownDetails details) {
//    widget.bloc.reDrawAdd(true);
    RenderBox referenceBox = context.findRenderObject();
    Offset localPosition = referenceBox.globalToLocal(details.globalPosition);
    widget.newX = selectedItemX = localPosition.dx;
    widget.newY = selectedItemY = localPosition.dy;

    if (isSelectedExtPuzzle(selectedItemX, selectedItemY, widget.puzzles)) {
      print('selected empty puzzle onPanDown');
      return;
    }
    widget.selectedPuzzle = getSelectedPuzzle(selectedItemX, selectedItemY);
    selectedTopX = widget.selectedPuzzle.rectScreen.left;
    selectedTopY = widget.selectedPuzzle.rectScreen.top;
    widget.indexOnScreen = getActualIndexOnScreen(selectedItemX, selectedItemY);
    direction = defectDirection(selectedItemX, selectedItemY);
    widget.puzzleTmp = widget.selectedPuzzle;

    if (direction == Direction.top) {
      distanceTop = selectedItemY - widget.selectedPuzzle.rectScreen.top;
      distanceBottom = widget.offsetBottomRight.dy - selectedItemY;
    }

    print('direction --- ${direction}');
  }

  List xs = [];
  List ys = [];

  void onPanUpdate(DragUpdateDetails details) {
    widget.gameState = GameState.playing;
    RenderBox referenceBox = context.findRenderObject();
    Offset localPosition = referenceBox.globalToLocal(details.globalPosition);
    widget.newX = localPosition.dx;
    widget.newY = localPosition.dy;
//    widget.puzzles.removeAt(widget.selectedPuzzle.index);

    if (direction == Direction.top) {
      PuzzleTile newPuzzle = widget.selectedPuzzle;
      if (widget.newY - distanceTop < widget.puzzleEmpty.rectScreen.top ||
          widget.newY + distanceBottom > widget.offsetBottomRight.dy) {
        return;
      }
      newPuzzle.rectScreen = Rect.fromLTWH(
          newPuzzle.rectScreen.left,
          widget.newY - distanceTop,
          newPuzzle.rectScreen.width,
          newPuzzle.rectScreen.height);
    }

    widget.bloc.reDrawAdd(true);
  }

  void onPanEnd(DragEndDetails details) {
    if (direction == Direction.top) {
      if (selectedItemY - widget.newY > widget.imageScreenHeight / 2) {
        widget.selectedPuzzle.rectScreen = Rect.fromLTWH(
            widget.selectedPuzzle.rectScreen.left,
            widget.puzzleEmpty.rectScreen.top,
            widget.selectedPuzzle.rectScreen.width,
            widget.selectedPuzzle.rectScreen.height);
      } else {
        widget.selectedPuzzle.rectScreen = Rect.fromLTWH(
            selectedTopX,
            selectedTopY,
            widget.selectedPuzzle.rectScreen.width,
            widget.selectedPuzzle.rectScreen.height);
      }
    }
    widget.puzzleTmp = null;
    widget.newY = 0.0;
    widget.newX = 0.0;
    widget.bloc.reDrawAdd(true);
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
