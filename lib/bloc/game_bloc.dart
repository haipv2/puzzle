import 'package:flutter/material.dart';

import 'bloc_helper/bloc_event_state.dart';
import 'game_event.dart';
import 'game_state.dart';
import 'package:rxdart/rxdart.dart';
class GameBloc extends BlocEventStateBase<GameEvent, GameState> {
  //controller
  BehaviorSubject<Image> controller = BehaviorSubject<Image>();
  //stream
  Observable<Image> get image => controller.stream;
  //sink
  Function(Image) get imageAdd => controller.sink.add;



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
