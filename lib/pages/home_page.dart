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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('build home_page');
    return Scaffold(
      body: MenuPage(),
    );
  }
}
