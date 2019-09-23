import 'package:flutter/material.dart';
import 'package:puzzle/bloc/bloc_provider.dart';
import 'package:puzzle/bloc/game_bloc.dart';
import 'package:puzzle/bloc/game_event.dart';

import 'game_page.dart';
import 'dart:ui' as ui show Image;

import 'pending_page.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String imgPath = '';
  Image image;
  GameBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<GameBloc>(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('menu_page');

    return BlocProvider<GameBloc>(
      bloc: bloc,
      child: StreamBuilder<Object>(
          stream: bloc.image,
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              imgPath = 'assets/images/level0.jpg';
              image = Image(
                image: AssetImage(imgPath),
                fit: BoxFit.cover,
              );
              bloc.imageAdd(image);
            }
            return snapshot.data == null
                ? PendingPage()
                : GridView.builder(
                    itemCount: 1,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          selectItem(context, image);
                        },
                        child: image,
                      );
                    });
          }),
    );
  }

  void selectItem(BuildContext context, Image image) {
    Size size= MediaQuery.of(context).size;
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return PuzzleGame(imgPath,size,3,3,bloc);
    }));
  }
}
