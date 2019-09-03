import 'dart:async';

import 'package:flutter/material.dart';
import 'package:puzzle/bloc/bloc_helper/bloc_event_state.dart';
import '../../repos/preferences.dart';
import '../global_bloc.dart';
import 'trans_event.dart';
import 'trans_state.dart';
import '../../commons/const.dart';

class TransBloc extends BlocEventStateBase<TransEvent, TransState> {
  StreamController<String> _langController =
      StreamController<String>.broadcast();

  Stream<String> get currentLanguage => _langController.stream;

  StreamController<Locale> _localeController = StreamController<Locale>();

  Stream<Locale> get currentLocale => _localeController.stream;

  @override
  void dispose() {
    _langController?.close();
    _localeController?.close();
  }

  void setNewLanguage(String newLanguage) async {
    //save the selected language as new preference
    var newLang = newLanguage.toString();
    await preferences.setPreferredLanguage(newLang);

    //Notification the translation module about new language
    await globalBloc.setNewLanguage(newLang);

    _langController.sink.add(newLang);
    _localeController.sink.add(globalBloc.locale);
  }

  @override
  Stream<TransState> eventHandler(
      TransEvent event, TransState currentState) async* {
    yield TransState.progressing(0);

    // Simulate a call to the authentication server
    await Future.delayed(const Duration(milliseconds: 1000));

    yield TransState.changed();

    if (currentState.changing) {
      for (int i = 0; i < 100; i += 20) {
        yield TransState.progressing(i);
      }
    }
  }

  void setSeeTips() async {
    //save see tips
    await preferences.setPreferredBool(IS_FIRST_TIME, true);
  }

  TransBloc() : super(initState: TransState.changed());
}
