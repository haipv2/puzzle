import 'package:flutter/material.dart';
import 'package:puzzle/bloc/bloc_provider.dart';
import 'package:puzzle/bloc/game_bloc.dart';
import 'package:puzzle/bloc/game_event.dart';

import 'game_page.dart';

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
    bloc = BlocProvider.of<GameBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GameBloc>(
      bloc: bloc,
      child: GridView.builder(
          itemCount: 1,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemBuilder: (context, index) {
            imgPath = 'assets/images/level$index.jpg';
            image = Image(
              image: AssetImage(imgPath),
              fit: BoxFit.cover,
            );
            return GestureDetector(
              onTap: () {
                selectItem(image);
                bloc.addEvent(GameEvent.playing());
              },
              child: image,
            );
          }),
    );
  }

  void selectItem(Image imgPath) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
//      return GamePage(MediaQuery.of(context).size, 'assets/images/level0.jpg', 2,2);
      return PuzzleGame(image);
    }));
  }
}
