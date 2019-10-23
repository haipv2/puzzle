import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:puzzle/bloc/bloc_provider.dart';
import 'package:puzzle/bloc/game_bloc.dart';
import 'package:puzzle/bloc/global_bloc.dart';
import 'package:puzzle/commons/app_style.dart';
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
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5,
      margin: EdgeInsets.all(10),
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
    String levelEasy = globalBloc.text('txtLevelEasy');
    String levelMedium = globalBloc.text('txtLevelMedium');
    String levelHard = globalBloc.text('txtLevelHard');
    String txtNobody = globalBloc.text('txtNobody');
    // Reusable alert style
    var alertStyle = AlertStyle(
      animationType: AnimationType.fromTop,
      isCloseButton: true,
      isOverlayTapDismiss: false,
      descStyle: TextStyle(fontWeight: FontWeight.bold),
      animationDuration: Duration(milliseconds: 400),
      backgroundColor: colorApp,
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(
          color: Colors.grey,
        ),
      ),
      titleStyle: commonStyleL,
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
                  color: Colors.yellow,
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              child: Column(
                children: <Widget>[
                  DialogButton(
                    color: Colors.amber,
                    child: Text(
                      levelEasy,
                      style: commonStyleM,
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
                        style: commonStyleS,
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
                    color: Colors.amber,
                    child: Text(
                      levelMedium,
                      style: commonStyleM,
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
                        style: commonStyleS,
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
                    color: Colors.amber,
                    child: Text(
                      levelHard,
                      style: commonStyleM,
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
                        style: commonStyleS,
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
