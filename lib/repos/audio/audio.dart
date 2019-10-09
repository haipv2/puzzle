import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class Audio {
  static AudioCache player = AudioCache();

  /// pre load all sounds
  ///
  static Future<dynamic> init() async {
    await player.loadAll([
      'audio/win.wav',
      'audio/swap.wav',
    ]);
  }

  static play() async {
    AudioPlayer player = AudioPlayer();
    await player.play('assets/audio/swap.wav', isLocal: true);
  }

  static playAsset(AudioType audioType) {
    player.play('audio/${describeEnum(audioType)}.wav');
  }
}

enum AudioType {
  swap,
  win,
}
