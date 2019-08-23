import 'package:flutter/material.dart';

import 'game_page.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        itemCount: 1,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (context, index) {
          var imgPath = 'assets/images/level$index.jpg';
          Image image = Image(image: AssetImage(imgPath),fit: BoxFit.cover,);
          return GestureDetector(
            onTap: () {
              selectItem(image);
            },
            child:image,
          );
        });
  }

  void selectItem(Image imgPath) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return GamePage(MediaQuery.of(context).size, 'assets/images/level0.jpg', 2,2);
    }));
  }
}
