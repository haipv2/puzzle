import 'package:flutter/material.dart';

import 'menu_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('build home_page');
    return Scaffold(
      body: MenuPage(),
    );
  }
}
