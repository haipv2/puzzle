import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:puzzle/bloc/bloc_provider.dart';
import 'package:puzzle/bloc/game_bloc.dart';
import 'package:puzzle/repos/firebase_database.dart';
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
  List<String> imageNameUrls;
  FirebaseDatabaseUtil firebaseDatabase;


  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<GameBloc>(context);
    firebaseDatabase = FirebaseDatabaseUtil();
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
              selectItem(context, imageUrl);
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

  void selectItem(BuildContext context, String imageUrl) {
    Size size = MediaQuery.of(context).size;
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return PuzzleGame(imageUrl, size, 2, 2, bloc);
    }));
  }
}
