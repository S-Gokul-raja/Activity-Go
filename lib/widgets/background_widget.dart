import 'package:activitygo/providers/my_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../my_theme.dart';

class BackGroundWidget extends StatelessWidget {
  final Color color;
  final double bgWidth, containerHeight;
  const BackGroundWidget(
      {Key? key,
      required this.color,
      required this.bgWidth,
      required this.containerHeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    MyThemeProvider myThemeProvider = Provider.of<MyThemeProvider>(context);
    return Container(
      height: containerHeight,
      decoration: MyTheme.boxDecoration.copyWith(
          border: Border.all(
            color: myThemeProvider.fontColor,
            width: 2,
          ),
          color: color),
      margin: EdgeInsets.only(
          left: 20 + bgWidth, right: 20, top: 10 + bgWidth, bottom: 20),
    );
  }
}
