import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'application.dart';
import 'package:puzzle/repos/audio/audio.dart';

import 'bloc/global_bloc.dart';
import 'repos/achievement/game_achieve.dart';
import 'repos/image/image_loader.dart';

void main() async {

  // Initialize the translations module
  await globalBloc.init();

  await Audio.init();

  await ImageLoader.getImageFileName();

  //remove status bar
  SystemChrome.setEnabledSystemUIOverlays([]);

  return runApp(Application());
}
