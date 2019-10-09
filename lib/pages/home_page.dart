import 'package:flutter/material.dart';
import 'package:puzzle/bloc/global_bloc.dart';

import 'menu_page.dart';
import 'widget/language_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String title = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    title = globalBloc.text('txtTitleGame');
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[InkWell(child: Icon(Icons.settings), onTap: openLangDialog,)],
        centerTitle: true,
        title: Text(title),
      ),
      body: MenuPage(),
    );
  }

  void openLangDialog() {
    showDialog(context: context, builder: (_){
      return LanguageSettingWidget();
    });
  }
}
