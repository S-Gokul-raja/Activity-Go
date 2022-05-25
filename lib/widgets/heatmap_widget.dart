import 'package:activitygo/providers/my_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:provider/provider.dart';

import '../my_theme.dart';
import '../providers/activity_provider.dart';

class HeatMapWidget extends StatelessWidget {
  final Activity activity;
  const HeatMapWidget({Key? key, required this.activity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime startDate = DateTime.now().add(const Duration(days: 100)),
        endDate = DateTime(1990);
    MyThemeProvider myThemeProvider = Provider.of<MyThemeProvider>(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Heatmap',
            style: MyTheme.title2,
          ),
          const SizedBox(
            height: 30,
          ),
          Container(
            alignment: Alignment.center,
            child: HeatMap(
              datasets: activity.sessions.map((session) {
                DateTime tempStart = DateTime(
                    session.start.year, session.start.month, session.start.day);
                if (tempStart.isAfter(endDate)) {
                  endDate = tempStart;
                }
                if (tempStart.isBefore(startDate)) {
                  startDate = tempStart;
                }
                return {session.start: session.duration.toInt()};
              }).fold(<DateTime, int>{}, (previousValue, element) {
                DateTime keyDateTime = element.keys.first;
                DateTime dateTime = DateTime(
                    keyDateTime.year, keyDateTime.month, keyDateTime.day);
                int value = element.values.first;
                if (previousValue != null) {
                  if (previousValue.containsKey(dateTime)) {
                    previousValue[dateTime] =
                        previousValue[dateTime] ?? 0 + value;
                  } else {
                    previousValue[dateTime] = value;
                  }
                }
                return previousValue;
              }),
              defaultColor: Colors.grey.withOpacity(0.25),
              colorMode: ColorMode.opacity,
              showText: false,
              scrollable: true,
              fontSize: 16,
              startDate: startDate.subtract(Duration(
                  days: endDate.difference(startDate).inDays > 7
                      ? 0
                      : 7 - endDate.difference(startDate).inDays)),
              endDate: endDate,
              margin: const EdgeInsets.all(3),
              textColor: myThemeProvider.fontColor,
              showColorTip: false,
              onClick: (DateTime dateTime) {},
              colorsets: {
                15: MyTheme.colors[activity.color],
              },
            ),
          ),
        ],
      ),
    );
  }
}
