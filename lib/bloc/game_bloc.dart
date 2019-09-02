import 'bloc_helper/bloc_event_state.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends BlocEventStateBase<GameEvent, GameState> {
  GameBloc() : super(initState: GameState.loading());

  @override
  Stream<GameState> eventhandler(
      GameEvent event, GameState currentState) async* {
    yield GameState.loading();
    await Future.delayed(const Duration(milliseconds: 1500));
    yield GameState.done();
  }
}
