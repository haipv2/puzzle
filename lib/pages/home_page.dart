import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:puzzle/bloc/bloc_provider.dart';
import 'package:puzzle/bloc/game_bloc.dart';
import 'package:puzzle/bloc/global_bloc.dart';
import 'package:puzzle/commons/app_style.dart';
import 'package:puzzle/repos/audio/audio.dart';
import 'package:puzzle/repos/game_setting.dart';
import 'package:puzzle/repos/preferences.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';

import 'game_dialog_animation.dart';
import 'menu_page.dart';
import 'widget/language_widget.dart';
import '../commons/const.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String title = '';
  bool soundOn = true;
  GameBloc bloc;
  AnimationController _dialogController;
  Animation<double> _quitAnimation;

  @override
  void initState() {
    super.initState();

    try {
      versionCheck(context);
    } catch (e) {
      print(e);
    }

    Audio.playAsset(AudioType.start);
    bloc = BlocProvider.of<GameBloc>(context);
    _dialogController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    _quitAnimation = Tween(begin: -1.0, end: 0.0).animate(
        CurvedAnimation(parent: _dialogController, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _dialogController.dispose();
    super.dispose();
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
            floatingActionButton: buildGameInfoBtn(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
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
          Audio.playAsset(AudioType.press);
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
    Audio.playAsset(AudioType.press);

    // Reusable alert style
    var alertStyle = AlertStyle(
        animationType: AnimationType.fromTop,
        isCloseButton: true,
        isOverlayTapDismiss: false,
        animationDuration: Duration(milliseconds: 400),
        backgroundColor: colorApp,
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(
            color: Colors.grey,
          ),
        ),
        titleStyle: commonStyleOnlyFontSize0,
        descStyle: commonStyleOnlyFontSize0);
    Alert(
      context: context,
      style: alertStyle,
      title: '',
      desc: '',
      buttons: [],
      closeFunction: () {},
      content: Container(height: 160, child: LanguageSettingWidget()),
    ).show();
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
                    Audio.playAsset(AudioType.press);
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: new Text(
                    globalBloc.text('txtYes'),
                    style: commonStyleM,
                  ),
                  onPressed: () {
                    Audio.playAsset(AudioType.press);
                    exit(0);
                  },
                )
              ],
            ),
          );
        });
  }

  Widget buildGameInfoBtn() {
    return FloatingActionButton(
      backgroundColor: colorApp,
      child: Icon(Icons.info),
      onPressed: () {
        String txtInfo = globalBloc.text('txtSupport');
        String txtInfoDesc = globalBloc.text('txtInfoDesc');

        // Reusable alert style
        var alertStyle = AlertStyle(
          animationType: AnimationType.fromTop,
          isCloseButton: true,
          isOverlayTapDismiss: false,
          animationDuration: Duration(milliseconds: 400),
          backgroundColor: colorApp,
          alertBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(
              color: Colors.grey,
            ),
          ),
          titleStyle: commonStyleL,
          descStyle: TextStyle(fontSize: 0),
        );
        Alert(
          context: context,
          style: alertStyle,
          title: txtInfo,
          desc: '',
          buttons: [],
          closeFunction: () {},
          content: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: colorApp,
                      borderRadius: BorderRadius.all(Radius.circular(15.0))),
                  child: Center(
                    child: Text(
                      txtInfoDesc,
                      style: commonStyleM,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ).show();
      },
    );
  }

  void versionCheck(BuildContext context) async {
    //Get Current installed version of app
    final PackageInfo info = await PackageInfo.fromPlatform();
    String newVerStr = info.version.trim();
    double newVersionNo = double.parse(newVerStr.replaceAll(".", ""));

    //Get Latest version info from firebase config
    final RemoteConfig remoteConfig = await RemoteConfig.instance;

    try {
      // Using default duration to force fetching from remote server.
      await remoteConfig.fetch(expiration: const Duration(seconds: 0));
      await remoteConfig.activateFetched();
      String currentVersion = remoteConfig.getString('currentVersion');
      double currentVersionNo =
          double.parse(currentVersion.trim().replaceAll(".", ""));
      if (newVersionNo > currentVersionNo) {
        _showVersionDialog(context, newVerStr);
      }
    } on FetchThrottledException catch (exception) {
      // Fetch throttled.
      print(exception);
    } catch (exception) {
      print('Unable to fetch remote config. Cached or default values will be '
          'used');
    }
  }

  void _showVersionDialog(BuildContext context, String newVersion) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = globalBloc.text('updateAppTitle');
        String message = globalBloc.text('updateAppContent');
        String btnLabel = globalBloc.text('updateBtn');
        String btnLabelCancel = globalBloc.text('quitBtn');
        return Platform.isIOS
            ? new CupertinoAlertDialog(
                title: Text(title),
                content: Text(message),
                actions: <Widget>[
                  FlatButton(
                    child: Text(btnLabel),
                    onPressed: () => _launchURL(APP_STORE_URL, newVersion),
                  ),
                  FlatButton(
                    child: Text(btnLabelCancel),
                    onPressed: () {
                      exit(0);
                    },
                  ),
                ],
              )
            : new AlertDialog(
                title: Text(title),
                content: Text(message),
                actions: <Widget>[
                  FlatButton(
                    child: Text(btnLabel),
                    onPressed: () => _launchURL(PLAY_STORE_URL, newVersion),
                  ),
                  FlatButton(
                    child: Text(btnLabelCancel),
                    onPressed: () {
                      exit(0);
                    },
                  ),
                ],
              );
      },
    );
  }

  _launchURL(String url, String newVersion) async {
    if (await canLaunch(url)) {
      await launch(url);
      await changeCurrentVersionRemote(newVersion);
    } else {
      throw 'Could not launch $url';
    }
  }

  changeCurrentVersionRemote(newVersion) async {
    //Get Latest version info from firebase config
    final RemoteConfig remoteConfig = await RemoteConfig.instance;
    remoteConfig.setDefaults(<String, String>{"currentVersion": newVersion});
  }
}
