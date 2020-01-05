import 'package:flutter/material.dart';
import 'package:puzzle/bloc/bloc_helper/bloc_event_state.dart';
import 'package:puzzle/bloc/global_bloc.dart';
import '../bloc/language/translations_bloc.dart';

class AppUtils {
  void changeLanguage(String langCode, TransBloc transBloc, BlocEvent event,
      BuildContext context, String txtLanguageSet) {
    if (langCode == globalBloc.currentLanguage) {
      try {
        Scaffold.of(context).showSnackBar(SnackBar(content: Text(txtLanguageSet)));
      } catch (e) {
        print(e);
      }
      return;
    }
    transBloc.setNewLanguage(langCode);
    transBloc.addEvent(event);
  }
}
