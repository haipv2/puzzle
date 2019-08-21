import 'package:flutter/material.dart';
import '../../commons/const.dart';
import '../../commons/app_style.dart';

class LanguageBtn extends StatefulWidget {
  final String langTxt;
  final String langCode;
  final TextStyle textStyle;
  final bool isSelected;
  VoidCallback onPressed;

  LanguageBtn(
      {@required this.onPressed,
      this.langTxt: ENGLISH_TXT,
      this.langCode: ENGLISH_CODE,
      this.textStyle: txtDisableStyle,
      this.isSelected: false});

  @override
  _LanguageBtnState createState() => _LanguageBtnState();
}

class _LanguageBtnState extends State<LanguageBtn> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text(
        widget.langTxt,
        style: widget.isSelected ? txtEnableStyle : txtDisableStyle,
      ),
      onPressed: widget.onPressed,
    );
  }
}
