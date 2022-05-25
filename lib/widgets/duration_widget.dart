import 'package:flutter/material.dart';

class DurationWidget extends StatelessWidget {
  final Duration duration;
  final Color color;
  const DurationWidget({Key? key, required this.duration, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(17),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (duration.inHours != 0)
            Text(
              duration.inHours.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          if (duration.inHours != 0)
            Text(
              ' HOUR' + (duration.inHours > 1 ? 'S' : ''),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: color,
              ),
            ),
          if (duration.inHours != 0 && (duration.inMinutes % 60) != 0)
            Text(
              ',',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: color,
              ),
            ),
          if ((duration.inMinutes % 60) != 0)
            Text(
              (duration.inMinutes % 60).toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          if ((duration.inMinutes % 60) != 0)
            Text(
              ' MINUTE' + (duration.inMinutes % 60 > 1 ? 'S' : ''),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: color,
              ),
            ),
        ],
      ),
    );
  }
}
