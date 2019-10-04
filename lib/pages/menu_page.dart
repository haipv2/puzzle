//import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:puzzle/bloc/bloc_provider.dart';
import 'package:puzzle/bloc/game_bloc.dart';
import 'package:puzzle/model/filedata.dart';
import 'package:puzzle/repos/firebase_database.dart';
import 'package:puzzle/repos/firebase_storage.dart';
import 'package:puzzle/repos/image/image_loader.dart';
import 'package:transparent_image/transparent_image.dart';

import 'game_page.dart';

import 'pending_page.dart';

enum ImageDownloadState { Idle, GettingURL, Downloading, Done, Error }

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String imgPath = '';
  Image image;
  GameBloc bloc;
  List<String> imageNames;
  FirebaseDatabaseUtil firebaseDatabase;
  FirebaseStorageUtil _firebaseStorageUtil;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<GameBloc>(context);
    firebaseDatabase = FirebaseDatabaseUtil();
//    _firebaseStorageUtil = FirebaseStorageUtil();
    imageNames = [];
    firebaseDatabase.getImageNames(imageNames);
    print(ImageLoader.imageUrls);
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
//              imgPath = 'assets/images/level0.jpg';
//              image = Image(
//                image: AssetImage(imgPath),
//                fit: BoxFit.cover,
//              );

              bloc.imageAddName([
                'https://firebasestorage.googleapis.com/v0/b/backend-puzzle.appspot.com/o/images%2Fq.png?alt=media&token=0c98e3c3-5a2d-4b0f-8bfe-47652b151d45'
              ]);
            }

            if (snapshot.data == null) {
//              bloc.imageAddName(imageNames);
              imageNames.add(
                  'https://firebasestorage.googleapis.com/v0/b/backend-puzzle.appspot.com/o/images%2Fq.png?alt=media&token=0c98e3c3-5a2d-4b0f-8bfe-47652b151d45');
              bloc.imageAddName(imageNames);
              return PendingPage();
            } else {
              return GridView.count(
                primary: true,
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                children: List.generate(imageNames.length, (index) {
                  return getStructuredGridCell(imageNames[index]);
                }),
              );
            }

//            return snapshot.data == null
//                ? PendingPage()
//                : GridView.builder(
//                    itemCount: 1,
//                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                        crossAxisCount: 2),
//                    itemBuilder: (context, index) {
//                      return GestureDetector(
//                        onTap: () {
//                          selectItem(context, image);
//                        },
//                        child: image,
//                      );
//                    });
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
              selectItem(context, image);
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

  void selectItem(BuildContext context, Image image) {
    Size size = MediaQuery.of(context).size;
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return PuzzleGame(imgPath, size, 2, 2, bloc);
    }));
  }
}
