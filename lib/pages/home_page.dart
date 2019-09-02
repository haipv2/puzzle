import 'package:flutter/material.dart';
import 'package:puzzle/bloc/bloc_provider.dart';
import 'package:puzzle/bloc/bloc_widget/bloc_state_builder.dart';
import 'package:puzzle/bloc/game_bloc.dart';
import 'package:puzzle/bloc/game_event.dart';
import 'package:puzzle/bloc/game_state.dart';

import 'menu_page.dart';
import 'pending_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GameBloc bloc;
  @override
  void initState() {
    bloc = BlocProvider.of<GameBloc>(context);
    bloc.addEvent(GameEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: BlocEventStateBuilder<GameState>(
          bloc: bloc, builder: (BuildContext context, GameState state) {
            if (state.loading){
              return PendingPage();
            }
            return MenuPage();

      }),
    );
  }
}
