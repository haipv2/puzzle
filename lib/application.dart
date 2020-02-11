import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'bloc/bloc_provider.dart';
import 'bloc/game_bloc.dart';
import 'bloc/language/translations_bloc.dart';
import 'pages/init_page.dart';

class Application extends StatefulWidget {
  @override
  _ApplicationState createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  @override
  void initState() {
    super.initState();
  }

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
                  fontFamily: 'vt323',
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
