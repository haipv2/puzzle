import 'dart:ui' as ui show Image;
import 'dart:ui';

class PuzzleTile {
  int curIndex;
  int index;
  Path path;
  ui.Image image;
  Offset offset;
  Rect rectScreen;
  Rect rectEmpty;
  Rect rectPaint;
  bool isEmpty;

  int getXIndex(int level) {
    return index % level;
  }

  int getYIndex(int level) {
    return (index / level).floor();
  }

  @override
  String toString() {
    return 'index:$index. RectPaint: L-${rectPaint.left}. T-${rectPaint.top}';
  }
}
