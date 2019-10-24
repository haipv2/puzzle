import 'dart:io';

import 'package:flutter/material.dart';
import 'package:puzzle/bloc/bloc_provider.dart';
import 'package:puzzle/bloc/game_bloc.dart';
import 'package:puzzle/bloc/global_bloc.dart';
import 'package:puzzle/commons/app_style.dart';
import 'package:puzzle/repos/game_setting.dart';
import 'package:puzzle/repos/preferences.dart';

import 'game_dialog_animation.dart';
import 'menu_page.dart';
import 'widget/language_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String title = '';
  bool soundOn = true;
  GameBloc bloc;
  Animation _lateAnimationMenu;
  AnimationController _dialogController;
  Animation<double> _quitAnimation;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<GameBloc>(context);
    _dialogController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    _quitAnimation = Tween(begin: -1.0, end: 0.0).animate(
        CurvedAnimation(parent: _dialogController, curve: Curves.elasticOut));
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _lateAnimationMenu = Tween(begin: -1.0, end: 0).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(0.3, 1.0, curve: Curves.fastOutSlowIn)));
  }

  @override
  void dispose() {
    _dialogController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

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
              leading: InkWell(
                onTap: () {
                  quit();
                },
                child: Icon(Icons.arrow_back),
              ),
              backgroundColor: colorApp,
              actions: <Widget>[
                buildSoundButton(snapshot),
                buildLangBtn,
              ],
              centerTitle: true,
              title: Text(title, style: commonStyleL),
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

  void quit() {
    _dialogController.forward();
    showDialog(
        context: context,
        builder: (_) {
          return GameDialogAnimate(
            animation: _quitAnimation,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              backgroundColor: colorApp,
              title: Text(
                globalBloc.text('txtQuitGame'),
                style: commonStyleM,
              ),
              content: Text(
                globalBloc.text('txtQuitGameConfirm'),
                style: commonStyleM,
              ),
              actions: <Widget>[
                FlatButton(
                  child: new Text(
                    globalBloc.text('txtNo'),
                    style: commonStyleM,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: new Text(
                    globalBloc.text('txtYes'),
                    style: commonStyleM,
                  ),
                  onPressed: () {
                    exit(0);
                  },
                )
              ],
            ),
          );
        });
  }
}
