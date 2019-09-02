import 'package:flutter/material.dart';
import 'package:puzzle/bloc/bloc_provider.dart';
import 'package:puzzle/bloc/bloc_widget/bloc_state_builder.dart';
import 'package:puzzle/bloc/game_bloc.dart';
import 'package:puzzle/bloc/game_event.dart';
import 'package:puzzle/bloc/game_state.dart';

import 'pending_page.dart';
import 'widget/puzzle_painter.dart';

class PuzzleGame extends StatefulWidget {
  final Image image;

  PuzzleGame(this.image);

  @override
  _PuzzleGameState createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  GameBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<GameBloc>(context);
    bloc.addEvent(GameEvent());
  }

  @override
  void dispose() {
    super.dispose();
    bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocEventStateBuilder<GameState>(
        bloc: bloc,
        builder: (BuildContext context, GameState state) {
          if (state.done) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return GestureDetector(
                  child: CustomPaint(
                    painter: PuzzlePainter(),
                  ),
                );
              }));
            });
          }
          if (state.loading) {
            return PendingPage();
          }
          return Container();
        },
      ),
    );
  }
}
