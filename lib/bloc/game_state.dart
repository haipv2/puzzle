import 'bloc_helper/bloc_event_state.dart';

class GameState extends BlocState {
  final bool loading;
  final bool buildingPuzzle;
  final bool playing;
  final bool done;

  GameState(
      {this.loading, this.playing, this.done, this.buildingPuzzle: false});

  factory GameState.buildingPuzzle() {
    return GameState(
        loading: false, playing: false, done: false, buildingPuzzle: true);
  }

  factory GameState.loading() {
    return GameState(loading: true, playing: false, done: false);
  }

  factory GameState.playing() {
    return GameState(loading: false, playing: true, done: false);
  }

  factory GameState.done() {
    return GameState(loading: false, playing: false, done: true);
  }
}
