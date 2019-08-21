import 'package:flutter/material.dart';

class PendingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Align(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
      ModalBarrier(
        dismissible: false,
        color: Colors.grey.withOpacity(0.3),
      )
    ]);
  }
}
