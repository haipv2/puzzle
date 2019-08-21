import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:puzzle/repos/preferences.dart';

const List<String> _supportedLang = ['en', 'vi'];
const String _defaultLang = 'vi';

class GlobalTrans {
  Locale _locale;
  Map<dynamic, dynamic> _localizedValues;
  Map<String, String> _cache = {};

  //get list supported locales
  Iterable<Locale> supportedLocales() =>
      _supportedLang.map<Locale>((lang) => Locale(lang, ''));

  // return corresponds lang
  String text(String key) {
    //return requested string
    String string = '** $key not found';
    if (_localizedValues != null) {
      // check if requested key in cache
      if (_cache[key] != null) {
        return _cache[key];
      }

      //iterate the key until found or not
      bool found = true;
      Map<dynamic, dynamic> _values = _localizedValues;
      List<String> _keyParts = key.split('.');
      int _keyPartsLen = _keyParts.length;
      int index = 0;
      int lastIndex = _keyPartsLen - 1;
      while (index < _keyPartsLen && found) {
        var value = _values[_keyParts[index]];

        if (value == null) {
          // not found => stop
          found = false;
          break;
        }

        //check if we found the requested key
        if (value is String && index == lastIndex) {
          string = value;

          // add to cache
          _cache[key] = string;
          break;
        }
        //go to next sub key
        _values = value;
        index++;
      }
    } else {
      return key;
    }
    return string;
  }

  String get currentLanguage => _locale == null ? '' : _locale.languageCode;

  Locale get locale => _locale;

  // one-time initialization
  Future<Null> init() async {
    if (_locale == null) {
      await setNewLanguage();
    }
    return null;
  }

  //routine to change the language
  Future<Null> setNewLanguage([String newLanguage]) async {
    String language = newLanguage;
    if (language == null) {
      language = await preferences.getPreferredLanguage();
    }

    // if not in the preferences. get current locale (device setting level)
    if (language == '') {
      String currentLocale = Platform.localeName.toLowerCase();
      if (currentLocale.length > 2) {
        if (currentLocale[2] == '-' || currentLocale[2] == '_') {
          language = currentLocale.substring(0, 2);
        }
      }
    }

    //check support language, not consider default one
    if (!_supportedLang.contains(language)) {
      language = '';
    }

    //set locale
    if (language == "") {
      language = preferences.defaultLanguage;
    }
    _locale = Locale(language, "");

    //load the language strings
    String jsonContent = await rootBundle
        .loadString('assets/locale/locale_${_locale.languageCode}.json');
    _localizedValues = json.decode(jsonContent);

    //clear cache
    _cache = {};
    return null;
  }

//Singleton factory
  static final GlobalTrans _translation = GlobalTrans._internal();

  factory GlobalTrans() {
    return _translation;
  }

  GlobalTrans._internal();
}

GlobalTrans globalBloc = GlobalTrans();
