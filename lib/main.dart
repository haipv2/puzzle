import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'application.dart';
import 'package:puzzle/repos/audio/audio.dart';

import 'repos/image/image_loader.dart';

void main() async {
//  await Audio.init();

  await ImageLoader.getImageFileName();

//  await ImageLoader.buildImageUrl();

  //remove status bar
  SystemChrome.setEnabledSystemUIOverlays([]);

  return runApp(Application());
}
