import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'application.dart';
import 'package:puzzle/repos/audio/audio.dart';

import 'repos/game_setting.dart';
import 'repos/image/image_loader.dart';

void main() async {

  // Initialize the translations module
  await GameSetting.init();

  await Audio.init();

  await ImageLoader.getImageFileName();
  await ImageLoader.downloadImages();

  //remove status bar
  SystemChrome.setEnabledSystemUIOverlays([]);

  return runApp(Application());
}
