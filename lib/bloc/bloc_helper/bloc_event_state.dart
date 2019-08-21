import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../bloc_provider.dart';

abstract class BlocEvent extends Object {}

abstract class BlocState extends Object {}

abstract class BlocEventStateBase<BlocEvent, BlocState> implements BlocBase {
  PublishSubject<BlocEvent> _eventController = PublishSubject<BlocEvent>();
  BehaviorSubject<BlocState> _stateController = BehaviorSubject<BlocState>();

  ///
  /// emit an event
  ///
  Function(BlocEvent) get addEvent => _eventController.sink.add;

  ///
  /// current/new event
  ///
  Stream<BlocState> get state => _stateController.stream;

  ///
  /// last state
  ///
  BlocState get lastState => _stateController.value;

  ///
  /// external processing of the event
  ///
  Stream<BlocState> eventhandler(BlocEvent event, BlocState currentState);

  ///
  /// initial state
  ///
  final BlocState initState;

  ///
  /// constructor
  ///
  BlocEventStateBase({@required this.initState}) {

    // when received event, invoke eventhandler and emit result new State
    _eventController.listen((BlocEvent event) {
      BlocState currentState = lastState ?? initState;
      eventhandler(event, currentState).forEach((BlocState newState) {
        _stateController.sink.add(newState);
      });
    });
  }

  ///
  @override
  void dispose() {

  }
}
