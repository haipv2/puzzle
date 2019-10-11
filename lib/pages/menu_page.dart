import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:puzzle/bloc/bloc_provider.dart';
import 'package:puzzle/bloc/game_bloc.dart';
import 'package:puzzle/bloc/global_bloc.dart';
import 'package:puzzle/commons/const.dart';
import 'package:puzzle/model/achievement.dart';
import 'package:puzzle/repos/achievement/game_achieve.dart';
import 'package:puzzle/repos/image/image_loader.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:transparent_image/transparent_image.dart';

import 'game_page.dart';
import 'pending_page.dart';
import '../model/image_info.dart' as game;

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String imgPath = '';
  Image image;
  GameBloc bloc;
  List<game.ImageInfo> imageInfos = [];

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<GameBloc>(context);
    imageInfos = [];
    buildImageUrl();
  }

  void buildImageUrl() async {
    StorageReference ref = FirebaseStorage.instance.ref();
    for (String imgName in ImageLoader.fileNames) {
      getDownloadUrl(ref, imgName);
    }
  }

  Future<void> getDownloadUrl(StorageReference ref, String item) async {
    String imgUrl = await ref.child('images/$item').getDownloadURL();
    imageInfos.add(game.ImageInfo()
      ..urls = imgUrl
      ..imageName = item);
    bloc.imageAddName(imageInfos);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GameBloc>(
      bloc: bloc,
      child: StreamBuilder<Object>(
          stream: bloc.imageNames,
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return PendingPage();
            } else {
              return GridView.count(
                primary: true,
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                children: List.generate(imageInfos.length, (index) {
                  return getStructuredGridCell(imageInfos[index]);
                }),
              );
            }
          }),
    );
  }

  Card getStructuredGridCell(game.ImageInfo imageInfo) {
    return new Card(
      child: Stack(
        children: <Widget>[
          Center(child: CircularProgressIndicator()),
          GestureDetector(
            onTap: () {
              loadImageAchievement(imageInfo.imageName);
              openDialogLevel(imageInfo.urls, GameAchievement.achievement);
            },
            child: Center(
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
//              image: file.picFile,
                image: imageInfo.urls,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void selectItem(String imageUrl, int gameLevelWidth, int gameLevelHeight,
      String gameLevel, Achievement achievement) {
    Size size = MediaQuery.of(context).size;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
      return PuzzleGame(imageUrl, size, gameLevelWidth, gameLevelHeight, bloc,
          gameLevel, achievement);
    }));
  }

  void openDialogLevel(String imageUrl, Achievement achievement) {
    String level = globalBloc.text('txtLevel');
    String selectLevel = globalBloc.text('txtSelectLevel');
    String levelEasy = globalBloc.text('txtLevelEasy');
    String levelMedium = globalBloc.text('txtLevelMedium');
    String levelHard = globalBloc.text('txtLevelHard');
    String txtHighest = globalBloc.text('txtHighest');
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
        '${achievement.userName} - move: ${achievement.moveStepEasy}';
    String bestMedium =
        '${achievement.userName} - move: ${achievement.moveStepMedium}';
    String bestHard =
        '${achievement.userName} - move: ${achievement.moveStepHard}';
    if (achievement.userName == null || achievement.userName.isEmpty) {
      bestHard = '';
      bestMedium = '';
      bestEasy = '';
    }
    Alert(
      context: context,
      style: alertStyle,
      title: level,
      desc: selectLevel,
      buttons: [
      ],
      closeFunction: (){},
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
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Align(
                        child: Text(
                          bestEasy,
                          style: TextStyle(fontSize: 10),
                        ),
                        alignment: Alignment.center,
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
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Align(
                        child: Text(
                          bestMedium,
                          style: TextStyle(fontSize: 10),
                        ),
                        alignment: Alignment.center,
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
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Align(
                        child: Text(
                          bestHard,
                          style: TextStyle(fontSize: 10),
                        ),
                        alignment: Alignment.center,
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
    Achievement result = await GameAchievement.getBestScore(imageName);
    return result;
  }
}
