import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:fireworks/fireworks.dart';
import 'package:flutter/material.dart';
import 'package:puzzle/bloc/game_bloc.dart';
import 'package:puzzle/bloc/global_bloc.dart';
import 'package:puzzle/commons/const.dart';
import 'package:puzzle/model/achievement.dart';
import 'package:puzzle/repos/achievement/game_achieve.dart';
import 'package:puzzle/repos/audio/audio.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'widget/game_button.dart';

class CompletePage extends StatefulWidget {
  final Achievement achievement;
  final String gameLevel;
  final String imagePath;
  bool isHigherScore;
  final Size size;
  final GameBloc bloc;
  final int gameLevelWidth;
  final int gameLevelHeight;
  final bool useHelp;
  final int newMove;

  CompletePage({this.achievement,
    this.newMove,
    this.useHelp,
    this.size,
    this.gameLevel,
    this.bloc,
    this.imagePath,
    this.gameLevelWidth,
    this.gameLevelHeight});

  @override
  _CompletePageState createState() => _CompletePageState();
}

class _CompletePageState extends State<CompletePage> {
  String txtPlayAgain = globalBloc.text('txtPlayAgain');
  String txtMenu = globalBloc.text('txtMenu');

  @override
  void initState() {
    super.initState();
    Audio.playAsset(AudioType.win);
    if (!widget.useHelp && widget.isHigherScore) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showNewHigherUser();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Container(
        decoration: BoxDecoration(
            color: Color.fromRGBO(250, 0, 250, 100),
            image: DecorationImage(
                image: NetworkImage(widget.imagePath), fit: BoxFit.fill)),
        child: Center(
          child: Stack(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: size.height * 0.75),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    GameButton(
                      onPress: () {
                        Audio.playAsset(AudioType.press);
                        Navigator.of(context).pop();
                      },
                      label: txtMenu,
                    ),
                  ],
                ),
              ),
              Fireworks(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> updateHigherScore(Achievement achievement) async {
    if (widget.gameLevel == GAME_LEVEL_EASY) {
      achievement.userNameEasy = userNameController.text;
      achievement.userNameEasyCountry = countryCode;
      achievement.moveStepEasy = widget.newMove;
    } else if (widget.gameLevel == GAME_LEVEL_MEDIUM) {
      achievement.userNameMedium = userNameController.text;
      achievement.userNameMediumCountry = countryCode;
      achievement.moveStepMedium = widget.newMove;
    } else if (widget.gameLevel == GAME_LEVEL_HARD) {
      achievement.userNameHard = userNameController.text;
      achievement.userNameHardCountry = countryCode;
      achievement.moveStepHard = widget.newMove;
    }

    await GameAchievement.updateNewScore(achievement);
  }

  TextEditingController userNameController = new TextEditingController();
  bool _validate = false;
  String errorText;
  String countryCode = 'vn';
  String txtSave = globalBloc.text('txtSave');
  String txtChampion = globalBloc.text('txtChampion');
  String txtUserName = globalBloc.text('txtUserName');
  String txtValidLength = globalBloc.text('txtValidLength');

  void showNewHigherUser() {
    // Reusable alert style
    var alertStyle = AlertStyle(
      animationType: AnimationType.fromTop,
      isCloseButton: true,
      isOverlayTapDismiss: true,
      descStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 0),
      animationDuration: Duration(milliseconds: 400),
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
        side: BorderSide(
          color: Colors.grey,
        ),
      ),
      titleStyle: TextStyle(
        color: Colors.red,
      ),
    );
    Alert(
      context: context,
      style: alertStyle,
      title: txtChampion,
      buttons: [],
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TextField(
            autofocus: true,
            onChanged: (text) {
              if (text.length == 0 || text.length < 3 || text.length > 20) {
                _validate = true;
              }
            },
            maxLength: 20,
            obscureText: false,
            controller: userNameController,
            decoration: InputDecoration(
                labelText: txtUserName,
                errorText: _validate ? txtValidLength : null,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide(color: Colors.grey, width: 1))),
          ),
          Wrap(direction: Axis.vertical, children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CountryPickerDropdown(
                initialValue: countryCode,
                itemBuilder: _buildDropdownItem,
                onValuePicked: (Country country) {
                  countryCode = country.isoCode;
                  print('${country.name}');
                },
              ),
            ),
          ]),
          DialogButton(
            child: Text(txtSave),
            onPressed: () {
              if (validateData()) updateHigherScore(widget.achievement);
              widget.isHigherScore = false;
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    ).show();
  }

  Widget _buildDropdownItem(Country country) {
    return Container(
      child: Row(
        children: <Widget>[
          CountryPickerUtils.getDefaultFlagImage(country),
          Text(
            '${country.name}',
            style: TextStyle(fontSize: 13),
          )
        ],
      ),
    );
  }

  bool validateData() {
    if (userNameController.text == null ||
        userNameController.text.length == 0) {
      errorText = 'The field is required.';
      _validate = false;
      return false;
    } else if (userNameController.text.length < 3 ||
        userNameController.text.length > 20) {
      errorText = 'The length is from 3-20.';
      _validate = false;
      return false;
    }
    return true;
  }
}
