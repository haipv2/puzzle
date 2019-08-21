import 'package:flt_rest/blocs/bloc_helper/bloc_event_state.dart';

class TransState extends BlocState {

  final bool changing;
  final bool changed;
  final int progress;

  TransState({this.changing: false, this.changed: false, this.progress: 0});

  factory TransState.progressing(int progress){
    return TransState(
      changing: true,
      progress: progress,
    );
  }

  factory TransState.changed(){
    return TransState(
      changing: false,
      changed: true,
      progress: 100,
    );
  }

}
