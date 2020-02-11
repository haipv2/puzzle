import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:puzzle/bloc/bloc_provider.dart';
import 'package:puzzle/bloc/game_bloc.dart';
import 'package:puzzle/commons/const.dart';
import 'package:puzzle/repos/image/image_loader.dart';

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
    initAds();
  }

  Future<void> buildImageUrl() async {
    StorageReference ref = FirebaseStorage.instance.ref();
    for (String imgName in ImageLoader.fileNames) {
      getDownloadUrl(ref, imgName);
    }
  }

  Future<void> getDownloadUrl(StorageReference ref, String item) async {
    try {
      String imgUrl = await ref.child('images/$item').getDownloadURL();
      imageInfos.add(game.ImageInfo()
        ..urls = imgUrl
        ..imageName = item);
      bloc.imageAddName(imageInfos);
    } catch (e) {
      print(e);
    }
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
              return Container(
                decoration: BoxDecoration(color: Color(0xFFFCF2C7)),
                child: GridView.count(
                  primary: true,
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  children: List.generate(imageInfos.length, (index) {
                    return ImageItemWidget(imageInfos[index]);
                  }),
                ),
              );
            }
          }),
    );
  }

  void initAds() {
    FirebaseAdMob.instance.initialize(appId: adsAppId).then((_) {
      MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
        keywords: <String>['flutterio', 'P-WORLD CUP'],
        contentUrl: 'https://flutter.io',
        childDirected: false,
        testDevices: <
            String>[], // Android emulators are considered test devices
      );

      BannerAd myBanner = BannerAd(
        adUnitId: adsAppUnit,
        size: AdSize.banner,
        targetingInfo: targetingInfo,
        listener: (MobileAdEvent event) {
          print("BannerAd event is $event");
        },
      );
      myBanner
        // typically this happens well before the ad is shown
        ..load()
        ..show(
          // Positions the banner ad 0 pixels from the bottom of the screen
          anchorOffset: 0.0,
          // Positions the banner ad 10 pixels from the center of the screen to the right
          horizontalCenterOffset: 0.0,
          // Banner Position
          anchorType: AnchorType.bottom,
        );
    });
  }

}
