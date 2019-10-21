import 'package:flutter/material.dart';
import 'package:puzzle/repos/preferences.dart';

import 'bloc/bloc_provider.dart';
import 'bloc/game_bloc.dart';
import 'bloc/language/translations_bloc.dart';
import 'commons/const.dart';
import 'pages/home_page.dart';
import 'pages/init_page.dart';
import 'pages/pending_page.dart';
import 'pages/tips_page.dart';

class Application extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TransBloc transBloc = TransBloc();
    return BlocProvider<GameBloc>(
      bloc: GameBloc(),
      child: BlocProvider<TransBloc>(
        bloc: transBloc,
        child: StreamBuilder(
            stream: transBloc.currentLocale,
            builder: (BuildContext context, AsyncSnapshot<Locale> snapshot) {
              return MaterialApp(
                title: 'Puzzle',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                  primaryColor: const Color(0xFF02BB9F),
                  primaryColorDark: const Color(0xFF167F67),
                  accentColor: const Color(0xFF167F67),
                ),
                home: InitPage(),
              );
            }),
      ),
    );
  }
}
