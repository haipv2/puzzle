import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'application.dart';
import 'audio/audio.dart';

void main() async {
//  await Audio.init();

  //remove status bar
  SystemChrome.setEnabledSystemUIOverlays([]);

  return runApp(Application());
}
