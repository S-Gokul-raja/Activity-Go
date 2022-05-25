import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../my_theme.dart';
import '../providers/activity_provider.dart';
import '../providers/my_theme_provider.dart';
import '../providers/session_provider.dart';

class AreaChartWidget extends StatelessWidget {
  const AreaChartWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<DateTime, int> dayWiseData = {};

    MyThemeProvider myThemeProvider = Provider.of<MyThemeProvider>(context);
    Activity activity = Provider.of<Activity>(context);
    for (Session session in activity.sessions) {
      DateTime sessionDay =
          DateTime(session.start.year, session.start.month, session.start.day);

      if (dayWiseData.containsKey(sessionDay)) {
        dayWiseData[sessionDay] =
            dayWiseData[sessionDay] ?? 0 + session.duration;
      } else {
        dayWiseData[sessionDay] = session.duration;
      }
    }
    List<SessionData> dayWiseDataList = [];

    dayWiseData.forEach((key, value) {
      dayWiseDataList.add(SessionData(DateFormat('y/MM/dd').format(key),
          double.parse((value / 60).toStringAsFixed(1))));
    });
    // dayWiseDataList.sort(
    //   (a, b) {
    //     return a.dateTime.compareTo(b.dateTime);
    //   },
    // );

    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Day wise',
            style: MyTheme.title2,
          ),
          const SizedBox(
            height: 30,
          ),
          dayWiseDataList.length <= 2
              ? Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Need 3 different session days',
                          maxLines: 2,
                          style: MyTheme.title2.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        CircularProgressIndicator(
                          color: MyTheme.colors[activity.color],
                        ),
                      ],
                    ),
                  ),
                )
              : Expanded(
                  child: SfCartesianChart(
                    tooltipBehavior: TooltipBehavior(
                        enable: true,
                        animationDuration: 3,
                        duration: 2,
                        borderColor: myThemeProvider.fontColor,
                        borderWidth: 5,
                        color: myThemeProvider.bgColor,
                        builder: (dynamic data, dynamic point, dynamic series,
                            int pointIndex, int seriesIndex) {
                          return Container(
                              padding: const EdgeInsets.all(3),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(point.x.toString()),
                                  Text(point.y.toString() + ' Hrs')
                                ],
                              ));
                        }),
                    plotAreaBorderWidth: 0,
                    primaryXAxis: CategoryAxis(
                      labelStyle: TextStyle(
                          fontSize: 12,
                          color: myThemeProvider.fontColor,
                          fontWeight: FontWeight.bold),
                      majorGridLines: const MajorGridLines(width: 0),
                      minorGridLines: const MinorGridLines(width: 0),
                      axisLine: const AxisLine(width: 0),
                      maximumLabels: 4,
                      majorTickLines: const MajorTickLines(size: 0),
                    ),
                    primaryYAxis: NumericAxis(
                      edgeLabelPlacement: EdgeLabelPlacement.hide,
                      labelStyle: TextStyle(
                          fontSize: 12,
                          color: myThemeProvider.fontColor,
                          fontWeight: FontWeight.bold),
                      maximumLabels: 2,
                      majorGridLines: const MajorGridLines(width: 0),
                      minorGridLines: const MinorGridLines(width: 0),
                      labelFormat: '{value} Hr',
                      axisLine: const AxisLine(width: 0),
                      majorTickLines: const MajorTickLines(size: 0),
                    ),
                    series: <ChartSeries>[
                      SplineAreaSeries<SessionData, String>(
                          dataSource: dayWiseDataList,
                          color:
                              MyTheme.colors[activity.color].withOpacity(0.9),
                          splineType: SplineType.cardinal,
                          cardinalSplineTension: 0.9,
                          sortingOrder: SortingOrder.ascending,
                          sortFieldValueMapper: (SessionData data, _) =>
                              data.dateTime,
                          xValueMapper: (SessionData data, _) => data.dateTime,
                          yValueMapper: (SessionData data, _) => data.duration)
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}

class SessionData {
  final String dateTime;
  final double duration;
  SessionData(this.dateTime, this.duration);
}
