import 'dart:math';
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
  Offset offsetDisableTop, offsetDisableBottom;

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
    puzzleEmpty.rectPaint = rectEmpty;
    puzzleEmpty.isEmpty = true;
    rectTemp = rectEmpty;
    paddingY = paddingYExt + imageScreenHeight;
    offsetMainLeft = Offset(paddingX, paddingY);
    imageEachHeight = image.height / gameLevelHeight;
    imageEachWidth = image.width / gameLevelWidth;
    offsetDisableTop = Offset(paddingX + imageScreenWidth, paddingY);
    offsetDisableBottom =
        Offset(paddingX + gameActiveWidth, paddingYExt + imageScreenHeight);

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
            imageScreenWidth,
            imageScreenHeight);

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
    result.shuffle();
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
  double distanceEmptyTopY, distanceEmptyTopX;

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
                        puzzleTileEmpty: widget.puzzleEmpty,
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
  double selectedTopX, selectedTopY, emptyTopY;
  List<PuzzleTile> movingPuzzleArr = [];

  void onPanDown(DragDownDetails details) {
    if (clickOutSideActiveScreen(details)) {
      return;
    }
    RenderBox referenceBox = context.findRenderObject();
    Offset localPosition = referenceBox.globalToLocal(details.globalPosition);
    widget.newX = selectedItemX = localPosition.dx;
    widget.newY = selectedItemY = localPosition.dy;

    widget.selectedPuzzle = getSelectedPuzzle(selectedItemX, selectedItemY);
    if (widget.selectedPuzzle.isEmpty) {
      return;
    }
    selectedTopX = widget.selectedPuzzle.rectPaint.left;
    selectedTopY = widget.selectedPuzzle.rectPaint.top;
    print('selectedTopX---${selectedTopX}');
    print('selectedTopY---${selectedTopY}');
    emptyTopY = widget.puzzleEmpty.rectPaint.top;
    widget.indexOnScreen = getActualIndexOnScreen(selectedItemX, selectedItemY);
    direction = defectDirection(selectedItemX, selectedItemY);
    widget.puzzleTmp = widget.selectedPuzzle;

    if (direction == Direction.top || direction == Direction.bottom) {
      distanceTop = selectedItemY - widget.selectedPuzzle.rectPaint.top;
      distanceBottom = widget.offsetBottomRight.dy - selectedItemY;
    }
    //move top over tile
//    if (direction == Direction.top) {
//      if (selectedTopY - widget.puzzleEmpty.rectPaint.top >
//          widget.imageScreenHeight) {
    distanceEmptyTopY = selectedItemY;
    movingPuzzleArr = getListItemInColumn(
        selectedItemY, widget.selectedPuzzle.index, direction);
//      }
    //move bottom over tile
//    }
    print('direction -- ${direction}');
//    print('movingPuzzleArr -- ${movingPuzzleArr}');
  }

  ///process holding
  void onPanUpdate(DragUpdateDetails details) {
    widget.gameState = GameState.playing;
    RenderBox referenceBox = context.findRenderObject();
    Offset localPosition = referenceBox.globalToLocal(details.globalPosition);
    widget.newX = localPosition.dx;
    widget.newY = localPosition.dy;

    if (direction == Direction.top) {
      // restrict drag item over screen.
      if (widget.newY - distanceTop < widget.puzzleEmpty.rectPaint.top ||
          widget.newY + distanceBottom > widget.offsetBottomRight.dy) {
        return;
      }
//      if (movingPuzzleArr.length == 0) {
//        widget.selectedPuzzle.rectPaint = Rect.fromLTWH(
//            widget.selectedPuzzle.rectPaint.left,
//            widget.newY - distanceTop,
//            widget.selectedPuzzle.rectPaint.width,
//            widget.selectedPuzzle.rectPaint.height);
//      } else {
      for (var i = 0; i < movingPuzzleArr.length; i++) {
        PuzzleTile puzzleTile = movingPuzzleArr[i];
        puzzleTile.rectPaint = Rect.fromLTWH(
            widget.selectedPuzzle.rectPaint.left,
            widget.newY - widget.imageScreenHeight * i - distanceTop,
            widget.selectedPuzzle.rectPaint.width,
            widget.selectedPuzzle.rectPaint.height);
//        }
      }
    } else if (direction == Direction.bottom) {
      // restrict drag item over screen.
      if (widget.newY - distanceTop > widget.puzzleEmpty.rectPaint.top) {
        return;
      }

      widget.selectedPuzzle.rectPaint = Rect.fromLTWH(
          widget.selectedPuzzle.rectPaint.left,
          widget.newY - distanceTop,
          widget.selectedPuzzle.rectPaint.width,
          widget.selectedPuzzle.rectPaint.height);
    }

    widget.bloc.reDrawAdd(true);
  }

  /// process touch up
  ///
  void onPanEnd(DragEndDetails details) {
    if (direction == Direction.top) {
      movingPuzzleArr
          .sort((a, b) => a.rectPaint.top.compareTo(b.rectPaint.top));
      if (selectedItemY - widget.newY > widget.imageScreenHeight / 2) {
        widget.puzzleEmpty.rectPaint = Rect.fromLTWH(
            widget.selectedPuzzle.rectPaint.left,
            selectedTopY,
            widget.selectedPuzzle.rectPaint.width,
            widget.selectedPuzzle.rectPaint.height);
        for (var i = 0; i < movingPuzzleArr.length; i++) {
          PuzzleTile puzzleTile = movingPuzzleArr[i];
          puzzleTile.rectPaint = Rect.fromLTWH(
              widget.selectedPuzzle.rectPaint.left,
              emptyTopY + widget.imageScreenHeight * i,
              widget.selectedPuzzle.rectPaint.width,
              widget.selectedPuzzle.rectPaint.height);
        }
      } else {
        for (var i = 0; i < movingPuzzleArr.length; i++) {
          PuzzleTile puzzleTile = movingPuzzleArr[i];
          puzzleTile.rectPaint = Rect.fromLTWH(
              selectedTopX,
              minY + widget.imageScreenHeight * i,
              widget.selectedPuzzle.rectPaint.width,
              widget.selectedPuzzle.rectPaint.height);
        }
      }
    } else if (direction == Direction.bottom) {
      if (widget.newY - selectedItemY > widget.imageScreenHeight / 2) {
        widget.puzzleEmpty.rectPaint = Rect.fromLTWH(
            widget.selectedPuzzle.rectPaint.left,
            selectedTopY,
            widget.selectedPuzzle.rectPaint.width,
            widget.selectedPuzzle.rectPaint.height);
        widget.selectedPuzzle.rectPaint = Rect.fromLTWH(
            widget.selectedPuzzle.rectPaint.left,
            emptyTopY,
            widget.selectedPuzzle.rectPaint.width,
            widget.selectedPuzzle.rectPaint.height);
      } else {
        widget.selectedPuzzle.rectPaint = Rect.fromLTWH(
            selectedTopX,
            selectedTopY,
            widget.selectedPuzzle.rectPaint.width,
            widget.selectedPuzzle.rectPaint.height);
      }
    }
    movingPuzzleArr = [];
    direction = null;
    widget.bloc.reDrawAdd(true);
  }

  ///
  /// defect direction
  ///
  Direction defectDirection(double currentItemX, double currentItemY) {
    int emptyIndexX = ((widget.puzzleEmpty.rectPaint.left - widget.paddingX) /
            widget.imageScreenWidth)
        .floor();
    print(
        'widget.puzzleEmpty.rectPaint.top --${widget.puzzleEmpty.rectPaint.top}');
    var paddingYTmp = (widget.puzzleEmpty.rectPaint.top - widget.paddingYExt);
    int emptyIndexY = (paddingYTmp / widget.imageScreenHeight).floor();

    int currentIndexX =
        ((currentItemX - widget.paddingX) / widget.imageScreenWidth).floor();
    var temp = (currentItemY - widget.paddingYExt) / widget.imageScreenHeight;

    int currentIndexY = (temp).floor();

    print('emptyIndexX---${emptyIndexX}');
    print('emptyIndexY---${emptyIndexY}');
    print('currentIndexX---${currentIndexX}');
    print('currentIndexY---${currentIndexY}');
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

//
//  bool isSelectedExtPuzzle(
//      double currentItemX, double currentItemY, List<PuzzleTile> puzzles) {
//    if (currentItemX > widget.paddingX &&
//        currentItemX < widget.rectTemp.right &&
//        currentItemY > widget.paddingYExt &&
//        currentItemY < widget.rectTemp.bottom) {
//      return true;
//    }
//    return false;
//  }

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
//    print('currentItemX--${currentItemX}');
//    print('currentItemY--${currentItemY}');
    try {
      result = widget.puzzles.firstWhere(
          (item) => (item.rectPaint.left < currentItemX &&
              item.rectPaint.right > currentItemX &&
              item.rectPaint.top < currentItemY &&
              item.rectPaint.bottom > currentItemY),
          orElse: () => widget.puzzleEmpty);
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

  bool clickOutSideActiveScreen(DragDownDetails details) {
    RenderBox referenceBox = context.findRenderObject();
    Offset localPosition = referenceBox.globalToLocal(details.globalPosition);
    if (localPosition.dx < widget.paddingX ||
        localPosition.dx > widget.paddingX + widget.gameActiveWidth ||
        localPosition.dy < widget.paddingYExt ||
        localPosition.dy > widget.offsetBottomRight.dy ||
        (localPosition.dy < widget.offsetDisableBottom.dy &&
            localPosition.dx > widget.offsetDisableTop.dx)) {
      return true;
    }
    return false;
  }

  List<PuzzleTile> getListItemInColumn(
      double distanceEmptyTop, int index, Direction direction) {
    List<PuzzleTile> subList = [];
    subList.add(widget.puzzles.firstWhere((item) => item.index == index));
    minY = widget.selectedPuzzle.rectPaint.top;
    do {
      if (direction == Direction.top) {
        distanceEmptyTop = distanceEmptyTop - widget.imageScreenHeight;
        if (distanceEmptyTop < widget.offsetMainLeft.dy) break;
      }
      PuzzleTile selectedPuzzle =
          getSelectedPuzzle(selectedItemX, distanceEmptyTop);

      if (selectedPuzzle.index != null && !selectedPuzzle.isEmpty) {
        minY = selectedPuzzle.rectPaint.top;
        subList.add(selectedPuzzle);
      }
    } while (distanceEmptyTop > widget.imageScreenHeight);
    print('minY---${minY}');
    subList.forEach((item) {
      print(item.index);
    });
    return subList;
  }
}
