import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:puzzle/bloc/bloc_provider.dart';
import 'package:puzzle/bloc/game_bloc.dart';
import 'package:puzzle/bloc/global_bloc.dart';
import 'package:puzzle/repos/firebase_database.dart';
import 'package:puzzle/repos/image/image_loader.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:transparent_image/transparent_image.dart';

import 'game_page.dart';
import 'pending_page.dart';


class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String imgPath = '';
  Image image;
  GameBloc bloc;
  List<String> imageNameUrls;


  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<GameBloc>(context);
    imageNameUrls = [];

    buildImageUrl();
  }

  void buildImageUrl() async {
    StorageReference ref = FirebaseStorage.instance.ref();
    for(String imgName in ImageLoader.fileNames){
      getDownloadUrl(ref, imgName);
    }
//    print (imageUrls);
  }
  Future<void> getDownloadUrl(StorageReference ref, String item)async{
    String imgUrl = await ref.child('images/$item').getDownloadURL();
    imageNameUrls.add(imgUrl.toString());
    bloc.imageAddName(imageNameUrls);
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
                children: List.generate(imageNameUrls.length, (index) {
                  return getStructuredGridCell(imageNameUrls[index]);
                }),
              );
            }

          }),
    );
  }

  Card getStructuredGridCell(String imageUrl) {
    return new Card(
      child: Stack(
        children: <Widget>[
          Center(child: CircularProgressIndicator()),
          GestureDetector(
            onTap: (){
              openDialogLevel(imageUrl);
            },
            child: Center(
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
//              image: file.picFile,
                image: imageUrl,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void selectItem(String imageUrl, int gameLevelWidth, int gameLevelHeight) {
    Size size = MediaQuery.of(context).size;
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return PuzzleGame(imageUrl, size, gameLevelWidth, gameLevelHeight, bloc);
    }));
  }

  void openDialogLevel(String imageUrl) {
    String level = globalBloc.text('txtLevel');
    String selectLevel = globalBloc.text('txtSelectLevel');
    // Reusable alert style
    var alertStyle = AlertStyle(
      animationType: AnimationType.fromTop,
      isCloseButton: false,
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

    Alert(
      context: context,
      style: alertStyle,
      title: level,
      desc: selectLevel,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DialogButton(
              child: Text(
                "Easy",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () => selectItem(imageUrl,2,3),
              color: Color.fromRGBO(0, 179, 134, 1.0),
              radius: BorderRadius.circular(15.0),
              gradient: LinearGradient(colors: [
                Color.fromRGBO(116, 116, 191, 1.0),
                Color.fromRGBO(52, 138, 199, 1.0)
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DialogButton(
              child: Text(
                "Medium",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () => selectItem(imageUrl,3,4),
              color: Color.fromRGBO(0, 179, 134, 1.0),
              radius: BorderRadius.circular(15.0),
              gradient: LinearGradient(colors: [
                Color.fromRGBO(116, 116, 191, 1.0),
                Color.fromRGBO(52, 138, 199, 1.0)
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DialogButton(
              child: Text(
                "Hard",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () => selectItem(imageUrl,4,5),
              color: Color.fromRGBO(0, 179, 134, 1.0),
              radius: BorderRadius.circular(15.0),
              gradient: LinearGradient(colors: [
                Color.fromRGBO(116, 116, 191, 1.0),
                Color.fromRGBO(52, 138, 199, 1.0)
              ]),
            ),
          ),
        ],
      ),
    ).show();
  }
}
