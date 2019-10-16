import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:puzzle/bloc/bloc_provider.dart';
import 'package:puzzle/bloc/game_bloc.dart';
import 'package:puzzle/repos/image/image_loader.dart';

import 'game_page.dart';
import 'item_image.dart';
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
                  return ImageItemWidget(imageInfos[index]);
                }),
              );
            }
          }),
    );
  }

}
