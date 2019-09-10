import 'dart:ui' as ui show Image;
import 'dart:ui';

class PuzzleTile {
  int curIndex;
  int index;
  Path path;
  Rect rect;
  ui.Image image;
  Offset offset;
  Rect rectScreen;
  bool isEmpty;

  int getXIndex(int level) {
    return index % level;
  }

  int getYIndex(int level) {
    return (index / level).floor();
  }
}