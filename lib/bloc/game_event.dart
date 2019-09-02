import 'bloc_helper/bloc_event_state.dart';

class GameEvent extends BlocEvent {
  GameEventType eventType;

  GameEvent();

  GameEvent.playing({this.eventType: GameEventType.playing});
}

enum GameEventType { start, init, playing }
