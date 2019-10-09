import 'package:flutter/material.dart';
import 'package:puzzle/bloc/bloc_provider.dart';
import 'package:puzzle/bloc/bloc_widget/bloc_state_builder.dart';
import 'package:puzzle/bloc/global_bloc.dart';
import 'package:puzzle/mixin/AppUtils.dart';
import '../../bloc/language/translations_bloc.dart';
import '../../bloc/language/trans_event.dart';
import '../../bloc/language/trans_state.dart';
import '../../commons/const.dart';


import '../pending_page.dart';
import 'language_btn.dart';

class LanguageSettingWidget extends StatelessWidget with AppUtils {
  LanguageSettingWidget();

  @override
  Widget build(BuildContext context) {
    TransBloc transBloc = BlocProvider.of<TransBloc>(context);
    return Container(
        child: BlocEventStateBuilder<TransState>(
            bloc: transBloc,
            builder: (BuildContext context, TransState state) {
              if (state.changing) {
                return PendingPage();
              }
              return Builder(builder: (BuildContext context) {
                return Dialog(
                  backgroundColor: Color(0xffF3E2A9),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      LanguageBtn(
                        langTxt: ENGLISH_TXT,
                        langCode: ENGLISH_CODE,
                        isSelected: globalBloc.currentLanguage == ENGLISH_CODE
                            ? true
                            : false,
                        onPressed: () {
                          changeLanguage(
                              ENGLISH_CODE, transBloc, TransEvent(), context);
                        },
                      ),
                      LanguageBtn(
                        langTxt: VIETNAM_TXT,
                        langCode: VIETNAM_CODE,
                        isSelected: globalBloc.currentLanguage == VIETNAM_CODE
                            ? true
                            : false,
                        onPressed: () {
                          changeLanguage(
                              VIETNAM_CODE, transBloc, TransEvent(), context);
                        },
                      ),
                    ],
                  ),
                );
              });
            }));
  }
}
