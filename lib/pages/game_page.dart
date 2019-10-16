import 'dart:async';
import 'dart:ui';
import 'dart:ui' as ui show Image, Codec, instantiateImageCodec;

import 'package:flutter/material.dart';
import 'package:puzzle/bloc/game_bloc.dart';
import 'package:puzzle/commons/const.dart';
import 'package:puzzle/commons/enums.dart';
import 'package:puzzle/model/achievement.dart';
import 'package:puzzle/model/puzzle_tile.dart';
import 'package:puzzle/repos/audio/audio.dart';
import 'package:puzzle/utils/game_engine.dart';

import 'complete_page.dart';
import 'pending_page.dart';
import 'widget/puzzle_painter.dart';

class PuzzleGame extends StatefulWidget {
  final String imgPath;
  final Size size;
  double gameActiveWidth;
  double gameActiveHeight;
  double paddingX, paddingY;
  int gameLevelWidth;
  int gameLevelHeight;
  int totalPuzzleTile;
  final String gameLevel;
  final Achievement achievement;

  GameBloc bloc;

  PuzzleGame(this.imgPath, this.size, this.gameLevelWidth, this.gameLevelHeight,
      GameBloc bloc, this.gameLevel, this.achievement) {
    this.bloc = bloc;
    paddingX = paddingY = size.width * 0.05;
    gameActiveWidth = size.width * 0.9;
    gameActiveHeight = size.height - paddingY * 4;
    totalPuzzleTile = gameLevelWidth * gameLevelHeight;
  }

  @override
  _PuzzleGameState createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> with TickerProviderStateMixin {
  Direction direction;
  double selectedItemX;
  double selectedItemY;
  double newItemX;
  double newItemY;

  double distanceEmptyTopY, distanceEmptyTopX;
  List<PuzzleTile> puzzles;
  ui.Image image;
  int imageSizeWidth;
  int imageSizeHeight;
  double imageScreenWidth;
  double imageScreenHeight;
  double imageEachWidth;
  double imageEachHeight;
  double paddingYExt;
  Rect rectEmpty;
  Rect rectTemp;
  GameState gameState;
  int selectedIndex;
  PuzzleTile selectedPuzzle;
  double minY, minX, maxX, maxY;
  PuzzleTile puzzleEmpty;
  double newX;
  double newY;
  int indexOnScreen;
  Offset offsetTopLeft;
  Offset offsetBottomRight;
  Offset offsetMainLeft;
  Offset offsetDisableTop, offsetDisableBottom;
  Offset offsetMove;
  Offset offsetHelp;

  AnimationController controller;
  Animation<int> animation;

  @override
  void initState() {
    super.initState();
    init(widget.imgPath);
  }

  Future<ui.Image> init(String imgPath) async {
    image = await getImage(imgPath);
    imageSizeWidth = image.width;
    imageSizeHeight = image.height;
    imageScreenWidth = widget.gameActiveWidth / widget.gameLevelWidth;
    imageScreenHeight = widget.gameActiveHeight / widget.gameLevelHeight;

    widget.gameActiveHeight = widget.gameActiveHeight - imageScreenHeight;
    imageScreenHeight = widget.gameActiveHeight / widget.gameLevelHeight;
    paddingYExt = widget.paddingY * 3;
    rectEmpty = Rect.fromLTWH(
        widget.paddingX, paddingYExt, imageScreenWidth, imageScreenHeight);
    offsetTopLeft = Offset(widget.paddingX, paddingYExt);
    offsetBottomRight = Offset(widget.size.width - widget.paddingX,
        widget.size.height - widget.paddingX);
    puzzleEmpty = new PuzzleTile();
    puzzleEmpty.rectPaint = rectEmpty;
    puzzleEmpty.isEmpty = true;
    rectTemp = rectEmpty;
    widget.paddingY = paddingYExt + imageScreenHeight;
    offsetMainLeft = Offset(widget.paddingX, widget.paddingY);
    imageEachHeight = image.height / widget.gameLevelHeight;
    imageEachWidth = image.width / widget.gameLevelWidth;

    offsetDisableTop =
        Offset(widget.paddingX + imageScreenWidth, widget.paddingY);
    offsetDisableBottom = Offset(widget.paddingX + widget.gameActiveWidth,
        paddingYExt + imageScreenHeight);

    await setPuzzles();
    offsetMove = Offset(widget.paddingX,
        paddingYExt + (widget.gameLevelHeight + 1) * imageScreenHeight);
    widget.bloc.puzzlesAdd(puzzles);
    return image;
  }

  @override
  void dispose() {
    controller?.dispose();
//    widget.bloc.dispose();
    super.dispose();
  }

  int move = 0;
  bool isMove = false;
  int second = 0;
  bool showHelp = false;
  bool isDone = false;
  int moveTmp = 0;

  @override
  Widget build(BuildContext context) {
//    gameState = GameState.done;
    return StreamBuilder<List<PuzzleTile>>(
        stream: widget.bloc.puzzles,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return PendingPage();
          }
          if (gameState == GameState.done) {
            bool isHigherScore =
                processHighScore(widget.achievement, widget.gameLevel);
//            Navigator.of(context).push(MaterialPageRoute(builder: (context){
//              return CompletePage(
//                  size: widget.size,
//                  bloc: widget.bloc,
//                  gameLevelHeight: widget.gameLevelHeight,
//                  gameLevelWidth: widget.gameLevelWidth,
//                  imagePath: widget.imgPath,
//                  achievement: widget.achievement,
//                  gameLevel: widget.gameLevel,
//                  isHigherScore: isHigherScore);
//            }));
            return CompletePage(
                size: widget.size,
                bloc: widget.bloc,
                gameLevelHeight: widget.gameLevelHeight,
                gameLevelWidth: widget.gameLevelWidth,
                imagePath: widget.imgPath,
                achievement: widget.achievement,
                gameLevel: widget.gameLevel,
                isHigherScore: isHigherScore);

          }
          return StreamBuilder<bool>(
              stream: widget.bloc.reDraw,
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  widget.bloc.reDrawAdd(true);
                }
                return Container(
                  decoration: BoxDecoration(color: Color(0xFFF6DDB1)),
                  child: GestureDetector(
                    child: CustomPaint(
                      painter: PuzzlePainter(
                          paddingX: widget.paddingX,
                          paddingY: widget.paddingY,
                          puzzles: puzzles,
                          puzzleTileEmpty: puzzleEmpty,
                          gameLevelWidth: widget.gameLevelWidth,
                          gameLevelHeight: widget.gameLevelHeight,
                          gameActiveWidth: widget.gameActiveWidth,
                          rectTemp: rectTemp,
                          gameState: gameState,
                          paddingYExt: paddingYExt,
                          imageScreenWidth: imageScreenWidth,
                          imageScreenHeight: imageScreenHeight,
                          orgImage: image)
                        ..reDraw = snapshot.data ?? false
                        ..move = move
                        ..second = second
                        ..showHelp = showHelp
                        ..isDone = isDone,
                    ),
                    onPanDown: onPanDown,
                    onPanUpdate: onPanUpdate,
                    onPanEnd: onPanUp,
                  ),
                );
              });
        });
  }

  double distanceTop, distanceBottom, distanceLeft, distanceRight;
  double originTopX, originTopY;
  double selectedTopX, selectedTopY, emptyTopY, emptyTopX;
  List<PuzzleTile> movingPuzzleArr = [];
  double movingY;
  double movingX;

  void onPanDown(DragDownDetails details) {
    if (clickOutSideActiveScreen(details)) {
      return;
    }
//    showHelp = !showHelp;
    RenderBox referenceBox = context.findRenderObject();
    Offset localPosition = referenceBox.globalToLocal(details.globalPosition);
    newX = selectedItemX = localPosition.dx;
    newY = selectedItemY = localPosition.dy;

    selectedPuzzle = getSelectedPuzzle(selectedItemX, selectedItemY);
    if (selectedPuzzle.isEmpty) {
      return;
    }
    selectedTopX = selectedPuzzle.rectPaint.left;
    selectedTopY = selectedPuzzle.rectPaint.top;
    emptyTopY = puzzleEmpty.rectPaint.top;
    emptyTopX = puzzleEmpty.rectPaint.left;
//    indexOnScreen = getActualIndexOnScreen(selectedItemX, selectedItemY);
    direction = defectDirection(selectedItemX, selectedItemY);

    if (direction == Direction.top || direction == Direction.bottom) {
      distanceTop = selectedItemY - selectedPuzzle.rectPaint.top;
      distanceBottom = offsetBottomRight.dy - selectedItemY;
    } else if (direction == Direction.left || direction == Direction.right) {
      distanceLeft = selectedItemX - selectedPuzzle.rectPaint.left;
      distanceRight = selectedPuzzle.rectPaint.right - selectedItemX;
    }
    distanceEmptyTopY = selectedItemY;
    movingPuzzleArr = getListItemMove(
        selectedItemX, selectedItemY, selectedPuzzle.index, direction);
  }

  ///process holding
  void onPanUpdate(DragUpdateDetails details) {
    gameState = GameState.playing;
    RenderBox referenceBox = context.findRenderObject();
    Offset localPosition = referenceBox.globalToLocal(details.globalPosition);
    newX = localPosition.dx;
    newY = localPosition.dy;

    if (direction == Direction.top) {
      // restrict drag item over screen.
      movingY = selectedItemY - newY;
      if (newY - distanceTop < puzzleEmpty.rectPaint.top ||
          newY + distanceBottom > offsetBottomRight.dy ||
          minY - movingY < puzzleEmpty.rectPaint.top) {
        return;
      }

      for (var i = 0; i < movingPuzzleArr.length; i++) {
        PuzzleTile puzzleTile = movingPuzzleArr[i];
        puzzleTile.rectPaint = Rect.fromLTWH(
            selectedPuzzle.rectPaint.left,
            newY - imageScreenHeight * i - distanceTop,
            selectedPuzzle.rectPaint.width,
            selectedPuzzle.rectPaint.height);
      }
    } else if (direction == Direction.bottom) {
      movingY = newY - selectedItemY;
      // restrict drag item over screen.
      if (newY - distanceTop < paddingYExt ||
          newY - distanceTop < selectedTopY ||
          selectedPuzzle.rectPaint.top < offsetTopLeft.dy ||
          newY - distanceTop > puzzleEmpty.rectPaint.top) {
        return;
      } else if (movingPuzzleArr.length > 1) {
        if (maxY + movingY > puzzleEmpty.rectPaint.bottom) {
          return;
        }
      }

      for (var i = 0; i < movingPuzzleArr.length; i++) {
        PuzzleTile puzzleTile = movingPuzzleArr[i];
        puzzleTile.rectPaint = Rect.fromLTWH(
            selectedPuzzle.rectPaint.left,
            newY + imageScreenHeight * i - distanceTop,
            selectedPuzzle.rectPaint.width,
            selectedPuzzle.rectPaint.height);
      }
    } else if (direction == Direction.left) {
      movingX = selectedItemX - newX;
      if (newX - distanceLeft < puzzleEmpty.rectPaint.left ||
          newX + distanceRight > offsetBottomRight.dx ||
          movingX < 0 ||
          minX - movingX < puzzleEmpty.rectPaint.left) {
        return;
      }

      for (var i = 0; i < movingPuzzleArr.length; i++) {
        PuzzleTile puzzleTile = movingPuzzleArr[i];
        puzzleTile.rectPaint = Rect.fromLTWH(
            newX - imageScreenWidth * i - distanceLeft,
            selectedPuzzle.rectPaint.top,
            selectedPuzzle.rectPaint.width,
            selectedPuzzle.rectPaint.height);
      }
    } else if (direction == Direction.right) {
      movingX = newX - selectedItemX;

      if (newX - distanceLeft < selectedPuzzle.rectPaint.left ||
          newX + distanceRight > puzzleEmpty.rectPaint.right ||
          movingX < 0 ||
          maxX + movingX > puzzleEmpty.rectPaint.right) {
        return;
      }

      for (var i = 0; i < movingPuzzleArr.length; i++) {
        PuzzleTile puzzleTile = movingPuzzleArr[i];
        puzzleTile.rectPaint = Rect.fromLTWH(
            newX + imageScreenWidth * i - distanceLeft,
            selectedPuzzle.rectPaint.top,
            selectedPuzzle.rectPaint.width,
            selectedPuzzle.rectPaint.height);
      }
    }

    widget.bloc.reDrawAdd(true);
  }

  /// process touch up
  ///
  void onPanUp(DragEndDetails details) {
    if (showHelp) {
      widget.bloc.reDrawAdd(true);
      return;
    }
    if (direction == Direction.top) {
      movingPuzzleArr
          .sort((a, b) => a.rectPaint.top.compareTo(b.rectPaint.top));
      if (selectedItemY - newY > imageScreenHeight / 2) {
        puzzleEmpty.rectPaint = Rect.fromLTWH(
            selectedPuzzle.rectPaint.left,
            selectedTopY,
            selectedPuzzle.rectPaint.width,
            selectedPuzzle.rectPaint.height);
        for (var i = 0; i < movingPuzzleArr.length; i++) {
          PuzzleTile puzzleTile = movingPuzzleArr[i];
          puzzleTile.rectPaint = Rect.fromLTWH(
              selectedPuzzle.rectPaint.left,
              emptyTopY + imageScreenHeight * i,
              selectedPuzzle.rectPaint.width,
              selectedPuzzle.rectPaint.height);
        }
        isMove = true;
      } else {
        for (var i = 0; i < movingPuzzleArr.length; i++) {
          PuzzleTile puzzleTile = movingPuzzleArr[i];
          puzzleTile.rectPaint = Rect.fromLTWH(
              selectedTopX,
              minY + imageScreenHeight * i,
              selectedPuzzle.rectPaint.width,
              selectedPuzzle.rectPaint.height);
        }
        isMove = false;
      }
    } else if (direction == Direction.bottom) {
      movingPuzzleArr
          .sort((a, b) => a.rectPaint.top.compareTo(b.rectPaint.top));
      if (newY - selectedItemY > imageScreenHeight / 2) {
        puzzleEmpty.rectPaint = Rect.fromLTWH(
            selectedPuzzle.rectPaint.left,
            selectedTopY,
            selectedPuzzle.rectPaint.width,
            selectedPuzzle.rectPaint.height);
        for (var i = 0; i < movingPuzzleArr.length; i++) {
          PuzzleTile puzzleTile = movingPuzzleArr[i];
          puzzleTile.rectPaint = Rect.fromLTWH(
              selectedPuzzle.rectPaint.left,
              minY + imageScreenHeight + imageScreenHeight * i,
              selectedPuzzle.rectPaint.width,
              selectedPuzzle.rectPaint.height);
        }
        isMove = true;
      } else {
        for (var i = 0; i < movingPuzzleArr.length; i++) {
          PuzzleTile puzzleTile = movingPuzzleArr[i];
          puzzleTile.rectPaint = Rect.fromLTWH(
              selectedTopX,
              minY + imageScreenHeight * i,
              selectedPuzzle.rectPaint.width,
              selectedPuzzle.rectPaint.height);
        }
        isMove = false;
      }
    } else if (direction == Direction.left) {
      movingPuzzleArr
          .sort((a, b) => a.rectPaint.left.compareTo(b.rectPaint.left));
      if (selectedItemX - newX > imageScreenWidth / 2) {
        puzzleEmpty.rectPaint = Rect.fromLTWH(
            selectedTopX,
            selectedPuzzle.rectPaint.top,
            selectedPuzzle.rectPaint.width,
            selectedPuzzle.rectPaint.height);
        for (var i = 0; i < movingPuzzleArr.length; i++) {
          PuzzleTile puzzleTile = movingPuzzleArr[i];
          puzzleTile.rectPaint = Rect.fromLTWH(
              emptyTopX + imageScreenWidth * i,
              selectedPuzzle.rectPaint.top,
              selectedPuzzle.rectPaint.width,
              selectedPuzzle.rectPaint.height);
        }
        isMove = true;
      } else {
        for (var i = 0; i < movingPuzzleArr.length; i++) {
          PuzzleTile puzzleTile = movingPuzzleArr[i];
          puzzleTile.rectPaint = Rect.fromLTWH(
              minX + imageScreenWidth * i,
              puzzleTile.rectPaint.top,
              selectedPuzzle.rectPaint.width,
              selectedPuzzle.rectPaint.height);
        }
        isMove = false;
      }
    } else if (direction == Direction.right) {
      movingPuzzleArr
          .sort((a, b) => a.rectPaint.left.compareTo(b.rectPaint.left));
      if (newX - selectedItemX > imageScreenWidth / 2) {
        puzzleEmpty.rectPaint = Rect.fromLTWH(
            selectedTopX,
            selectedPuzzle.rectPaint.top,
            selectedPuzzle.rectPaint.width,
            selectedPuzzle.rectPaint.height);
        for (var i = 0; i < movingPuzzleArr.length; i++) {
          PuzzleTile puzzleTile = movingPuzzleArr[i];
          puzzleTile.rectPaint = Rect.fromLTWH(
              minX + imageScreenWidth + imageScreenWidth * i,
              selectedPuzzle.rectPaint.top,
              selectedPuzzle.rectPaint.width,
              selectedPuzzle.rectPaint.height);
        }
        isMove = true;
      } else {
        for (var i = 0; i < movingPuzzleArr.length; i++) {
          PuzzleTile puzzleTile = movingPuzzleArr[i];
          puzzleTile.rectPaint = Rect.fromLTWH(
              minX + imageScreenWidth * i,
              puzzleTile.rectPaint.top,
              selectedPuzzle.rectPaint.width,
              selectedPuzzle.rectPaint.height);
        }
        isMove = false;
      }
    }
    if (isMove) {
      move++;
      playSound(AudioType.swap);
    }
    widget.bloc.reDrawAdd(true);

    if (isCompletedGame()) {
      print('game done!');
      moveTmp = move;
      move = 0;
      second = 0;
      isDone = true;
      gameState = GameState.done;
      setState(() {});
//      widget.bloc.reDrawAdd(false);
    } else {
      print('game NOT DONE!');
    }
    movingPuzzleArr = [];
    direction = null;
    distanceTop = 0;
    distanceBottom = 0;
    maxY = minY = maxX = minX = 0;
    movingY = movingX = 0;
  }

  ///
  /// defect direction
  ///
  Direction defectDirection(double currentItemX, double currentItemY) {
    var emptyTmpX = ((puzzleEmpty.rectPaint.left) / imageScreenWidth);
    int emptyIndexX = emptyTmpX.floor();
    var paddingYTmp = (puzzleEmpty.rectPaint.top);
    int emptyIndexY = (paddingYTmp / imageScreenHeight).floor();

    int currentIndexX =
        ((selectedPuzzle.rectPaint.left) / imageScreenWidth).floor();
    var currentItemYTmp = (selectedPuzzle.rectPaint.top);

    var temp = currentItemYTmp / imageScreenHeight;

    int currentIndexY = (temp).floor();

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

  PuzzleTile getSelectedPuzzle(double currentItemX, double currentItemY) {
    PuzzleTile result;
    try {
      result = puzzles.firstWhere(
          (item) => (item.rectPaint.left < currentItemX &&
              item.rectPaint.right > currentItemX &&
              item.rectPaint.top < currentItemY &&
              item.rectPaint.bottom > currentItemY),
          orElse: () => puzzleEmpty);
    } catch (e) {
      print(e);
    }
    return result;
  }

  int getActualIndexOnScreen(double dX, double dY, int index) {
    print('dx--${dX}. dy-- ${dY}--index ${index}');
    var x = (dX - widget.paddingX);
    var y = (dY - paddingYExt - imageScreenHeight);
    var result = (x ~/ imageScreenWidth) + (y ~/ imageScreenHeight);
    return result;
  }

  bool clickOutSideActiveScreen(DragDownDetails details) {
    RenderBox referenceBox = context.findRenderObject();
    Offset localPosition = referenceBox.globalToLocal(details.globalPosition);
    if (localPosition.dx < widget.paddingX ||
        localPosition.dx > widget.paddingX + widget.gameActiveWidth ||
        localPosition.dy < paddingYExt ||
        localPosition.dy > offsetBottomRight.dy ||
        (localPosition.dy < offsetDisableBottom.dy &&
            localPosition.dx > offsetDisableTop.dx)) {
//      if (clickShowHelp(details)) {
//        showHelp = !showHelp;
//      }
      return true;
    }
    return false;
  }

  ///
  /// get all puzzle in line which will be moved.
  ///
  List<PuzzleTile> getListItemMove(double selectedItemX, double selectedItemY,
      int index, Direction direction) {
    List<PuzzleTile> subList = [];
    subList.add(puzzles.firstWhere((item) => item.index == index));
    minY = selectedPuzzle.rectPaint.top;
    minX = selectedPuzzle.rectPaint.left;
    maxY = selectedPuzzle.rectPaint.bottom;
    maxX = selectedPuzzle.rectPaint.right;

    PuzzleTile selectedPuzzleTmp;
    if (direction == Direction.top) {
      do {
        if (selectedItemY - puzzleEmpty.rectPaint.top < imageScreenHeight * 2)
          break;
        selectedItemY = selectedItemY - imageScreenHeight;
        selectedPuzzleTmp = getSelectedPuzzle(selectedItemX, selectedItemY);
        if (selectedPuzzleTmp.isEmpty) break;
        minY = selectedPuzzleTmp.rectPaint.top;
        subList.add(selectedPuzzleTmp);
      } while (selectedItemY > imageScreenHeight);
    } else if (direction == Direction.bottom) {
      do {
        selectedItemY = selectedItemY + imageScreenHeight;
        selectedPuzzleTmp = getSelectedPuzzle(selectedItemX, selectedItemY);
        if (selectedPuzzleTmp.isEmpty) break;
        subList.add(selectedPuzzleTmp);
        maxY = selectedPuzzleTmp.rectPaint.bottom;
      } while (selectedItemY < puzzleEmpty.rectPaint.top);
    } else if (direction == Direction.left) {
      do {
        if (selectedItemX - puzzleEmpty.rectPaint.left < imageScreenWidth * 2)
          break;

        selectedItemX = selectedItemX - imageScreenWidth;
        selectedPuzzleTmp = getSelectedPuzzle(selectedItemX, selectedItemY);
        if (selectedPuzzleTmp.isEmpty) break;
        minX = selectedPuzzleTmp.rectPaint.left;
        subList.add(selectedPuzzleTmp);
      } while (selectedItemX > imageScreenWidth);
    } else if (direction == Direction.right) {
      do {
        selectedItemX = selectedItemX + imageScreenWidth;
        selectedPuzzleTmp = getSelectedPuzzle(selectedItemX, selectedItemY);
        if (selectedPuzzleTmp.isEmpty) break;
        maxX = selectedPuzzleTmp.rectPaint.right;
        subList.add(selectedPuzzleTmp);
      } while (selectedItemX < puzzleEmpty.rectPaint.right);
    }
    return subList;
  }

  List<PuzzleTile> orgList = [];

  Future<List<PuzzleTile>> buildPuzzles() async {
    PuzzleTile firstPuzzle;
    List<PuzzleTile> resultTmp = [];
    for (int i = 0; i < widget.gameLevelHeight; i++) {
      for (int j = 0; j < widget.gameLevelWidth; j++) {
        Rect rectScreen = Rect.fromLTWH(
            widget.paddingX + j * imageScreenWidth,
            widget.paddingY + i * imageScreenHeight,
            imageScreenWidth,
            imageScreenHeight);

        PictureRecorder pictureRecorder = PictureRecorder();
        Canvas canvas = Canvas(pictureRecorder,
            Rect.fromLTWH(0, 0, imageEachWidth, imageEachHeight));

        Rect rect3 = Rect.fromLTWH(j * imageEachWidth, i * imageEachHeight,
            imageEachWidth, imageEachHeight);
        Rect rect4 = Rect.fromLTWH(0, 0, rect3.width, rect3.height);
        var imageIndex = i * widget.gameLevelWidth + j;

        canvas.drawImageRect(image, rect3, rect4, Paint());
        ui.Image imageExtract = await pictureRecorder
            .endRecording()
            .toImage(imageEachWidth.floor(), imageEachHeight.floor());
        if (i == 0 && j == 0) {
          firstPuzzle = PuzzleTile()
            ..isEmpty = false
            ..index = imageIndex
            ..image = imageExtract
            ..rectScreen = rectScreen;
        } else {
          resultTmp.add(PuzzleTile()
            ..isEmpty = false
            ..index = imageIndex
            ..image = imageExtract
            ..rectScreen = rectScreen);
        }
      }
    }

    orgList
      ..add(firstPuzzle)
      ..addAll(resultTmp);
    GameEngine.shufflePuzzleTile(resultTmp);
    List<PuzzleTile> result = []
      ..add(firstPuzzle)
      ..addAll(resultTmp);

    return result;
  }

  Future<List<PuzzleTile>> setPuzzles() async {
    puzzles = await buildPuzzles();
    return puzzles;
  }

  Completer<ImageInfo> completer = Completer();

  Future<ui.Image> getImage(String path) async {
    var img = new NetworkImage(path);
    img
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info);
    }));
    ImageInfo imageInfo = await completer.future;
    return imageInfo.image;
  }

  bool isCompletedGame() {
    if (puzzles[0].rectPaint.top == paddingYExt) {
      return false;
    }
    for (int i = 0; i < puzzles.length; i++) {
      print('i= ${i}. ${puzzles[i]}');

      if (isCorrectPos(i)) {
        continue;
      } else {
        return false;
      }
    }
    return true;
  }

  bool isCorrectPos(int i) {
    PuzzleTile puzzleTile = puzzles[i];
    if (puzzleTile.index < widget.gameLevelWidth) {
      if (puzzleTile.rectPaint.left ==
              imageScreenWidth * puzzleTile.index + widget.paddingX &&
          puzzleTile.rectPaint.top == imageScreenHeight + paddingYExt) {
        return true;
      } else {
        return false;
      }
    } else {
      if (puzzleTile.rectPaint.left ==
              imageScreenWidth * (puzzleTile.index % widget.gameLevelWidth) +
                  widget.paddingX &&
          puzzleTile.rectPaint.top ==
              imageScreenHeight * (puzzleTile.index ~/ widget.gameLevelWidth) +
                  paddingYExt +
                  imageScreenHeight) {
        return true;
      } else {
        return false;
      }
    }
  }

  bool clickShowHelp(DragDownDetails details) {
    RenderBox referenceBox = context.findRenderObject();
    Offset localPosition = referenceBox.globalToLocal(details.globalPosition);

    return true;
  }

  Future<void> playSound(AudioType audioType) async {
    // Play sound
    await Audio.playAsset(audioType);
  }

  bool processHighScore(Achievement achievement, String gameLevel) {
    if (gameLevel == GAME_LEVEL_EASY) {
      if (achievement.moveStepEasy > moveTmp) {
        achievement.moveStepEasy = moveTmp;
        return true;
      }
    } else if (gameLevel == GAME_LEVEL_MEDIUM) {
      if (achievement.moveStepMedium > moveTmp) {
        achievement.moveStepMedium = moveTmp;
        return true;
      }
    } else if (gameLevel == GAME_LEVEL_HARD) {
      if (achievement.moveStepHard > moveTmp) {
        achievement.moveStepHard = moveTmp;
        return true;
      }
    }
    return false;
  }
}
