import 'package:flutter/material.dart';
import 'package:puzzle/bloc/bloc_provider.dart';
import 'package:puzzle/bloc/game_bloc.dart';
import 'package:puzzle/commons/const.dart';
import 'package:puzzle/repos/preferences.dart';

import 'home_page.dart';
import 'pending_page.dart';
import 'tips_page.dart';

class InitPage extends StatefulWidget {
  @override
  _InitPageState createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    preferences.getBool(IS_FIRST_TIME).then((data) {
      if (data == null || data == false) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (BuildContext contect) {
          return TipsPage();
        }));
      } else {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (BuildContext contect) {
          return HomePage();
        }));
      }
    });
    return PendingPage();
  }
}
