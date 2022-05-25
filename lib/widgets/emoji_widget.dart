import 'package:activitygo/providers/my_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmojiWidget extends StatelessWidget {
  final String emoji;
  final Color color;
  final double size;
  const EmojiWidget(
      {Key? key, required this.emoji, required this.color, required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    MyThemeProvider myThemeProvider = Provider.of<MyThemeProvider>(context);
    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: myThemeProvider.fontColor,
          width: 2,
        ),
      ),
      child: Text(
        emoji,
        style: TextStyle(fontSize: size / 2),
      ),
    );
  }
}
