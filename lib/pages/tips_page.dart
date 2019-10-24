import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:puzzle/bloc/bloc_provider.dart';
import 'package:puzzle/bloc/bloc_widget/bloc_state_builder.dart';
import 'package:puzzle/bloc/global_bloc.dart';
import 'package:puzzle/bloc/language/trans_state.dart';
import 'package:puzzle/bloc/language/translations_bloc.dart';
import 'package:puzzle/commons/app_style.dart';
import 'package:puzzle/commons/const.dart';
import 'package:puzzle/mixin/AppUtils.dart';

import 'home_page.dart';
import 'pending_page.dart';
import 'widget/custom_flat_button.dart';
import 'widget/language_widget.dart';

class TipsPage extends StatefulWidget {
  @override
  _TipsPageState createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> with AppUtils {
  @override
  void initState() {
    super.initState();
  }

  TransBloc transBloc;
  GlobalKey<ScaffoldState> _tipScaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    transBloc = BlocProvider.of<TransBloc>(context);
    final String newLanguage = globalBloc.currentLanguage == VIETNAM_CODE
        ? VIETNAM_CODE
        : ENGLISH_CODE;
    return SafeArea(
      child: BlocEventStateBuilder<TransState>(
          bloc: transBloc,
          builder: (BuildContext context, TransState state) {
            if (state.changing) {
              return PendingPage();
            }
            return Scaffold(
              key: _tipScaffoldKey,
              body: Swiper.children(
                  autoplay: false,
                  index: 0,
                  loop: false,
                  pagination: SwiperPagination(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                    builder: DotSwiperPaginationBuilder(
                        color: Colors.black,
                        activeColor: Colors.blueAccent,
                        size: 6.5,
                        activeSize: 8.0),
                  ),
                  control: SwiperControl(
                    iconNext: Icons.arrow_forward,
                    iconPrevious: Icons.arrow_back,
                  ),
                  children: _buildTipsPage(context, transBloc, newLanguage)),
            );
          }),
    );
  }

  List<Widget> _buildTipsPage(
      BuildContext context, TransBloc transBloc, String newLanguage) {
    List<Widget> result = [];
    result.add(Container(
        color: colorApp,
        child: ListView(children: <Widget>[
          Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Center(
                child: Text(
                  globalBloc.text('txtTips0Title'),
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: tipsPageTitleStyle,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              LanguageSettingWidget(),
            ],
          )
        ])));
    result.add(Container(
        color: colorApp,
        child: ListView(children: <Widget>[
          Column(
            children: <Widget>[
              Center(
                child: Text(
                  globalBloc.text('txtTips1Rule'),
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: tipsPageTitleStyleM,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: Align(
                  child: RichText(
                      text: TextSpan(
                          text: globalBloc.text('txtTips1Desc'),
                          style: tipsPageDescStyle)),
                ),
              ),
            ],
          )
        ])));
    result.add(Container(
      color: colorApp,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.only(top: 50.0, right: 15.0, left: 15.0),
              child: CustomFlatButton(
                  title: globalBloc.text('txtTips2Play'),
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  textColor: Colors.black87,
                  onPressed: () {
                    setState(() {
                      // retrieve bloc
                      transBloc.setSeeTips();
                    });
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context){
                      return HomePage();
                    }));
                  },
                  splashColor: Colors.black12,
                  borderColor: Colors.black,
                  borderWidth: 2,
                  color: Colors.orangeAccent),
            )
          ],
        ),
      ),
    ));
    return result;
  }
}
