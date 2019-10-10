import 'package:flutter/material.dart';
import 'package:fireworks/fireworks.dart';
import 'package:puzzle/repos/audio/audio.dart';
import 'dart:ui' as ui show Image;

import 'widget/game_button.dart';

class CompletePage extends StatefulWidget {
  final String imagePath;

  CompletePage(this.imagePath);

  @override
  _CompletePageState createState() => _CompletePageState();
}

class _CompletePageState extends State<CompletePage> {
  @override
  void initState() {
    super.initState();
    Audio.playAsset(AudioType.win);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
          color: Color.fromRGBO(250, 0, 250, 100),
          image: DecorationImage(
              image: NetworkImage(widget.imagePath), fit: BoxFit.cover)),
//      decoration: BoxDecoration(color: Colors.red),
      child: Center(
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  left: size.width * 0.3, top: size.height * 0.75),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GameButton(
                      onPress: (){},
                      label:'PLAY AGAIN',
                    ),
                  ),
                  GameButton(
                    onPress: (){},
                    label:'PLAY MORE',
                  ),
                ],
              ),
            ),
            Fireworks(),
          ],
        ),
      ),
    );
  }
}
