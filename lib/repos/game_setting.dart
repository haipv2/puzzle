import 'package:puzzle/bloc/global_bloc.dart';
import 'package:puzzle/repos/preferences.dart';

class GameSetting {
  static bool soundOn;

  static init() async {
    initLang();
    var soundSetting = await preferences.getSoundSetting();
    soundOn = soundSetting;
  }

  static initLang() async {
    await globalBloc.init();
  }

}
