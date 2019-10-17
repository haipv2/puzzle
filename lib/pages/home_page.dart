import 'package:flutter/material.dart';
import 'package:puzzle/bloc/bloc_provider.dart';
import 'package:puzzle/bloc/game_bloc.dart';
import 'package:puzzle/bloc/global_bloc.dart';
import 'package:puzzle/repos/game_setting.dart';
import 'package:puzzle/repos/preferences.dart';

import 'menu_page.dart';
import 'widget/language_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String title = '';
  bool soundOn = true;
  GameBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<GameBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    title = globalBloc.text('txtTitleGame');
    var buildLangBtn = IconButton(
      icon: Icon(Icons.language),
      onPressed: openLangDialog,
    );
    return StreamBuilder<bool>(
        stream: bloc.gameSettingStream,
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              actions: <Widget>[
                buildSoundButton(snapshot),
                buildLangBtn,
              ],
              centerTitle: true,
              title: Text(title),
            ),
            body: MenuPage(),
          );
        });
  }

  Widget buildSoundButton(AsyncSnapshot<bool> snapshot) {
    IconData iconData = Icons.volume_off;
    if (GameSetting.soundOn) {
      iconData = Icons.volume_up;
    }
    return IconButton(
      icon: Icon(iconData),
      onPressed: () async {
        if (GameSetting.soundOn) {
          GameSetting.soundOn = false;
        } else {
          GameSetting.soundOn = true;
        }
        await preferences.setSoundSetting(GameSetting.soundOn);
        bloc.gameSettingAdd(GameSetting.soundOn);
      },
    );
  }

  void openLangDialog() {
    showDialog(
        context: context,
        builder: (_) {
          return LanguageSettingWidget();
        });
  }

}
