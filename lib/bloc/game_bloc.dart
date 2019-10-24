import 'package:flutter/material.dart';
import 'package:puzzle/model/puzzle_tile.dart';

import 'bloc_helper/bloc_event_state.dart';
import 'game_event.dart';
import 'game_state.dart';
import 'package:rxdart/rxdart.dart';
import '../model/image_info.dart' as game;

class GameBloc extends BlocEventStateBase<GameEvent, GameState> {
  //controller
  BehaviorSubject<Image> imageController = BehaviorSubject<Image>();
  //stream
  Observable<Image> get image => imageController.stream;
  //sink
  Function(Image) get imageAdd => imageController.sink.add;

  //controller
  BehaviorSubject<List<game.ImageInfo>> imageControllerURL = BehaviorSubject<List<game.ImageInfo>>();
  //stream
  Observable<List<game.ImageInfo>> get imageNames => imageControllerURL.stream;
  //sink
  Function(List<game.ImageInfo>) get imageAddName => imageControllerURL.sink.add;

  //List puzzle
  BehaviorSubject<List<PuzzleTile>> puzzlesController = BehaviorSubject<List<PuzzleTile>>();
  Observable<List<PuzzleTile>> get puzzles => puzzlesController.stream;
  Function(List<PuzzleTile>) get puzzlesAdd => puzzlesController.sink.add;

  //Draw patiner flag
  BehaviorSubject<bool> painterController = BehaviorSubject<bool>();
  Observable<bool> get reDraw => painterController.stream;
  Function(bool) get reDrawAdd => painterController.sink.add;

  //game setting stream
  BehaviorSubject<bool> gameSettingController = BehaviorSubject<bool>();
  Observable<bool> get gameSettingStream => gameSettingController.stream;
  Function(bool) get gameSettingAdd => gameSettingController.sink.add;


  GameBloc() : super(initState: GameState.loading());

  @override
  Stream<GameState> eventHandler(
      GameEvent event, GameState currentState) async* {
    if (currentState.loading) {
      await Future.delayed(const Duration(milliseconds: 1000));
      yield GameState.done();
    }
  }

  @override
  void dispose() {
    imageController?.close();
    puzzlesController?.close();
    painterController?.close();
    gameSettingController?.close();
    imageControllerURL?.close();
    super.dispose();
  }
}
