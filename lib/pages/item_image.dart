import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:puzzle/bloc/bloc_provider.dart';
import 'package:puzzle/bloc/game_bloc.dart';
import 'package:puzzle/bloc/global_bloc.dart';
import 'package:puzzle/commons/const.dart';
import 'package:puzzle/model/achievement.dart';
import 'package:puzzle/repos/achievement/game_achieve.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:transparent_image/transparent_image.dart';
import '../model/image_info.dart' as game;
import 'game_page.dart';

class ImageItemWidget extends StatefulWidget {
  final game.ImageInfo imageInfo;

  ImageItemWidget(this.imageInfo);

  @override
  _ImageItemWidgetState createState() => _ImageItemWidgetState();
}

class _ImageItemWidgetState extends State<ImageItemWidget> {
  Achievement achievement;

  @override
  void initState() {
    super.initState();
    loadImageAchievement(widget.imageInfo.imageName);
  }

  @override
  Widget build(BuildContext context) {
    return new Card(
      child: Stack(
        children: <Widget>[
          Center(child: CircularProgressIndicator()),
          GestureDetector(
            onTap: () {
              openDialogLevel(widget.imageInfo.urls, achievement);
            },
            child: Center(
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
//              image: file.picFile,
                image: widget.imageInfo.urls,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void openDialogLevel(String imageUrl, Achievement achievement) {
    String level = globalBloc.text('txtLevel');
    String selectLevel = globalBloc.text('txtSelectLevel');
    String levelEasy = globalBloc.text('txtLevelEasy');
    String levelMedium = globalBloc.text('txtLevelMedium');
    String levelHard = globalBloc.text('txtLevelHard');
    String txtHighest = globalBloc.text('txtHighest');
    String txtNobody = globalBloc.text('txtNobody');
    // Reusable alert style
    var alertStyle = AlertStyle(
      animationType: AnimationType.fromTop,
      isCloseButton: true,
      isOverlayTapDismiss: false,
      descStyle: TextStyle(fontWeight: FontWeight.bold),
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
    String bestEasy =
        '${achievement.userNameEasy} - move: ${achievement.moveStepEasy}';
    String bestEasyCountry = achievement.userNameEasyCountry == ''
        ? null
        : achievement.userNameEasyCountry;
    String bestMedium =
        '${achievement.userNameMedium} - move: ${achievement.moveStepMedium}';
    String bestMediumCountry = achievement.userNameMediumCountry == ''
        ? null
        : achievement.userNameMediumCountry;
    String bestHard =
        '${achievement.userNameHard} - move: ${achievement.moveStepHard}';
    String bestHardCountry = achievement.userNameHardCountry == ''
        ? null
        : achievement.userNameHardCountry;
    if (achievement.userNameEasy == null || achievement.userNameEasy.isEmpty) {
      bestEasy = txtNobody;
    }
    if (achievement.userNameMedium == null ||
        achievement.userNameMedium.isEmpty) {
      bestMedium = txtNobody;
    }
    if (achievement.userNameHard == null || achievement.userNameHard.isEmpty) {
      bestHard = txtNobody;
    }
    Alert(
      context: context,
      style: alertStyle,
      title: level,
      desc: selectLevel,
      buttons: [],
      closeFunction: () {},
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              child: Column(
                children: <Widget>[
                  DialogButton(
                    child: Text(
                      levelEasy,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () => selectItem(
                        imageUrl, 2, 2, GAME_LEVEL_EASY, achievement),
                    radius: BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 3.0, 10.0, 3.0),
                        child:
                            (bestEasyCountry != null || bestEasyCountry == '')
                                ? CountryPickerUtils.getDefaultFlagImage(
                                    CountryPickerUtils.getCountryByIsoCode(
                                        bestEasyCountry))
                                : Container(),
                      ),
                      Text(
                        bestEasy,
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              child: Column(
                children: <Widget>[
                  DialogButton(
                    child: Text(
                      levelMedium,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () => selectItem(
                        imageUrl, 3, 4, GAME_LEVEL_MEDIUM, achievement),
                    radius: BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 3.0, 10.0, 3.0),
                        child: (bestMediumCountry != null ||
                                bestMediumCountry == '')
                            ? CountryPickerUtils.getDefaultFlagImage(
                                CountryPickerUtils.getCountryByIsoCode(
                                    bestMediumCountry))
                            : Container(),
                      ),
                      Text(
                        bestMedium,
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              child: Column(
                children: <Widget>[
                  DialogButton(
                    child: Text(
                      levelHard,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () => selectItem(
                        imageUrl, 4, 5, GAME_LEVEL_HARD, achievement),
                    radius: BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 3.0, 10.0, 3.0),
                        child:
                            (bestHardCountry != null || bestHardCountry == '')
                                ? CountryPickerUtils.getDefaultFlagImage(
                                    CountryPickerUtils.getCountryByIsoCode(
                                        bestHardCountry))
                                : Container(),
                      ),
                      Text(
                        bestHard,
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).show();
  }

  Future<Achievement> loadImageAchievement(String imageName) async {
    achievement = await GameAchievement.getBestScore(imageName);
    return achievement;
  }

  void selectItem(String imageUrl, int gameLevelWidth, int gameLevelHeight,
      String gameLevel, Achievement achievement) {
    GameBloc bloc = BlocProvider.of<GameBloc>(context);
    Size size = MediaQuery.of(context).size;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
      return PuzzleGame(imageUrl, size, gameLevelWidth, gameLevelHeight, bloc,
          gameLevel, achievement);
    }));
  }
}
