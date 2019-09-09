import 'package:flutter/material.dart';
import 'package:puzzle/model/puzzle_tile.dart';

import 'bloc_helper/bloc_event_state.dart';
import 'game_event.dart';
import 'game_state.dart';
import 'package:rxdart/rxdart.dart';
class GameBloc extends BlocEventStateBase<GameEvent, GameState> {
  //controller
  BehaviorSubject<Image> imageController = BehaviorSubject<Image>();
  //stream
  Observable<Image> get image => imageController.stream;
  //sink
  Function(Image) get imageAdd => imageController.sink.add;

  //List puzzle
  BehaviorSubject<List<PuzzleTile>> puzzlesController = BehaviorSubject<List<PuzzleTile>>();
  Observable<List<PuzzleTile>> get puzzles => puzzlesController.stream;
  Function(List<PuzzleTile>) get puzzlesAdd => puzzlesController.sink.add;

  //Draw patiner flag
  BehaviorSubject<bool> painterController = BehaviorSubject<bool>();
  Observable<bool> get reDraw => painterController.stream;
  Function(bool) get reDrawAdd => painterController.sink.add;


  GameBloc() : super(initState: GameState.loading());

  @override
  Stream<GameState> eventHandler(
      GameEvent event, GameState currentState) async* {
    if (currentState.loading) {
      await Future.delayed(const Duration(milliseconds: 1500));
      yield GameState.done();
    }
  }
}
