import 'package:flutter/material.dart';
import 'package:puzzle/bloc/bloc_provider.dart';
import 'package:puzzle/bloc/global_bloc.dart';
import 'package:puzzle/bloc/language/translations_bloc.dart';

import '../home_page.dart';
import 'language_widget.dart';

class ShopDrawer extends StatelessWidget {
  String txtSetting = globalBloc.text('txtSetting');
  String txtLanguage = globalBloc.text('txtLanguage');
  @override
  Widget build(BuildContext context) {
    TransBloc _transBloc = BlocProvider.of<TransBloc>(context);
    Size size = MediaQuery.of(context).size;
      return SizedBox(
        width: size.width * 3 / 4,
        child: Drawer(
            elevation: 2,
            child: Container(
              color: const Color(0xffF3E2A9),
              child: Column(
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    accountName: Text('test'),
                    accountEmail: Text('test'),
                    currentAccountPicture: Hero(
                      tag: '',
                      child: CircleAvatar(
                        child: Icon(Icons.insert_emoticon),
                        backgroundColor: Colors.white,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(txtLanguage),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (_) {
                            return LanguageSettingWidget();
                          });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.exit_to_app),
                    title: Text('Logout'),
                    onTap: () {
                      Navigator.of(context)
                          .pushReplacement(
                          MaterialPageRoute(builder: (context) {
//                            removeUserInfo();
                            return HomePage();
                          }));
                    },
                  ),
                ],
              ),
            )),
      );
    }
}
