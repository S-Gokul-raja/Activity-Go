import 'package:activitygo/providers/activities_provider.dart';
import 'package:activitygo/pages/activity_page.dart';
import 'package:activitygo/widgets/emoji_widget.dart';
import 'package:activitygo/my_theme.dart';
import 'package:activitygo/pages/new_activity_page.dart';
import 'package:activitygo/pages/new_session_page.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/my_theme_provider.dart';
import '../providers/activity_provider.dart';
import '../widgets/background_widget.dart';
import '../providers/session_provider.dart';

class ActivitiesPage extends StatefulWidget {
  static const String routeName = '/activities';
  const ActivitiesPage({Key? key}) : super(key: key);

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  bool isInit = false;
  late Activities activities;
  late MyThemeProvider myThemeProvider;
  bool showOnlyFavorites = false;

  @override
  Future<void> didChangeDependencies() async {
    if (!isInit) {
      myThemeProvider = Provider.of<MyThemeProvider>(context);
      activities = Provider.of<Activities>(context);
      isInit = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              iconSize: 30,
              icon: Icon(myThemeProvider.isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode),
              color: myThemeProvider.fontColor,
              onPressed: () {
                myThemeProvider.toggle();
              },
            ),
            IconButton(
              iconSize: 30,
              icon: Icon(showOnlyFavorites
                  ? Icons.all_inclusive_sharp
                  : Icons.favorite),
              color: myThemeProvider.fontColor,
              onPressed: () {
                setState(() {
                  showOnlyFavorites = !showOnlyFavorites;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(NewActivityPage.routeName,
                    arguments: <String, Activity?>{
                      "activity": null,
                    }).then(
                  (result) {
                    if (result != null) {
                      Map<String, dynamic> newResult =
                          result as Map<String, dynamic>;
                      if (newResult['new']) {
                        activities
                            .addActivity(newResult['activity'] as Activity);
                        if (showOnlyFavorites) {
                          activities.addFavorites(newResult['activity'].id);
                        }
                      }
                    }
                  },
                );
              },
              child: Text(
                'New Activity + ',
                style: TextStyle(
                  fontSize: MyTheme.title2.fontSize,
                  color: Colors.blue,
                ),
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                showOnlyFavorites ? 'Favorites' : 'All Activities',
                style: MyTheme.title1,
              ),
            ),
            const Divider(
              color: Colors.grey,
            ),
            if (showOnlyFavorites &&
                activities.favorites.isNotEmpty &&
                activities.activitiesList.any((activity) =>
                    activities.favorites.contains(activity.id) &&
                    activity.sessions.isNotEmpty))
              Container(
                height: 200,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(20),
                child: PieChart(
                  PieChartData(
                    sections: List.generate(
                      activities.favorites.length,
                      (index) {
                        Activity activity = activities.activitiesList
                            .firstWhere((activity) =>
                                activity.id == activities.favorites[index]);

                        return PieChartSectionData(
                          color: MyTheme.colors[activity.color],
                          value: activity.totalSessionsDuration.inMinutes
                              .toDouble(),
                          radius: 30,
                          title: null,
                          badgeWidget: EmojiWidget(
                            color: MyTheme.colors[activity.color],
                            emoji: activity.emoji,
                            size: 35,
                          ),
                          showTitle: false,
                          borderSide: BorderSide(
                              color: myThemeProvider.fontColor,
                              width: 2,
                              style: BorderStyle.none),
                          badgePositionPercentageOffset: 1.2,
                        );
                      },
                    ),
                  ),
                ),
              ),
            if (activities.favorites.isEmpty && showOnlyFavorites)
              activities.activitiesState == ActivitiesState.done
                  ? Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'No Favorites Yet',
                        style: MyTheme.title2.copyWith(
                          color: myThemeProvider.fontColor,
                        ),
                      ),
                    )
                  : Container(),
            if (activities.activitiesList.isEmpty && !showOnlyFavorites)
              activities.activitiesState == ActivitiesState.done
                  ? Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'No Activities Yet',
                        style: MyTheme.title2.copyWith(
                          color: myThemeProvider.fontColor,
                        ),
                      ),
                    )
                  : Container(),
            if (activities.activitiesList.isNotEmpty &&
                activities.activitiesState == ActivitiesState.done)
              ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 20),
                itemCount: activities.activitiesList.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  double bgWidth = 7, containerHeight = 100;

                  bool isFavorite = activities.favorites
                      .contains(activities.activitiesList[index].id);
                  if (showOnlyFavorites && !isFavorite) {
                    return Container();
                  }
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(ActivityPage.routeName,
                              arguments: activities.activitiesList[index])
                          .then((result) {
                        if (result != null) {
                          Map<String, dynamic> newResult =
                              result as Map<String, dynamic>;
                          if (newResult['delete']) {
                            activities.removeActivity(
                                activities.activitiesList[index]);
                          } else {
                            setState(() {});
                          }
                        } else {
                          setState(() {});
                        }
                      });
                    },
                    child: Stack(
                      children: [
                        BackGroundWidget(
                          bgWidth: bgWidth,
                          containerHeight: containerHeight,
                          color: MyTheme
                              .colors[activities.activitiesList[index].color],
                        ),
                        Container(
                          height: containerHeight,
                          decoration: MyTheme.boxDecoration.copyWith(
                            border: Border.all(
                              color: myThemeProvider.fontColor,
                              width: 2,
                            ),
                            color: myThemeProvider.bgColor,
                          ),
                          margin: EdgeInsets.only(
                              left: 20,
                              right: 20 + bgWidth,
                              top: 10,
                              bottom: 20 + bgWidth),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 50 - 20,
                                      ),
                                      Expanded(
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(left: 10),
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            activities
                                                .activitiesList[index].title,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: MyTheme.title2.copyWith(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            if (isFavorite) {
                                              activities.removeFavorites(
                                                  activities
                                                      .activitiesList[index]
                                                      .id);
                                            } else {
                                              activities.addFavorites(activities
                                                  .activitiesList[index].id);
                                            }
                                          },
                                          child: Icon(
                                            isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: isFavorite
                                                ? MyTheme.colors[activities
                                                    .activitiesList[index]
                                                    .color]
                                                : myThemeProvider.fontColor,
                                            size: 25,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).pushNamed(
                                                NewSessionPage.routeName,
                                                arguments: {
                                                  'activity': activities
                                                      .activitiesList[index]
                                                }).then((result) {
                                              if (result != null) {
                                                Map<String, dynamic> newResult =
                                                    result
                                                        as Map<String, dynamic>;
                                                if (newResult['new']) {
                                                  activities
                                                      .activitiesList[index]
                                                      .addSession(
                                                          newResult['session']
                                                              as Session);
                                                }
                                              }
                                            });
                                          },
                                          child: Icon(
                                            Icons.add,
                                            size: 25,
                                            color: myThemeProvider.fontColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (activities
                                                .activitiesList[index]
                                                .totalSessionsDuration
                                                .inHours !=
                                            0)
                                          AutoSizeText(
                                            activities.activitiesList[index]
                                                .totalSessionsDuration.inHours
                                                .toString(),
                                            minFontSize: 12,
                                            style: TextStyle(
                                              color: myThemeProvider.fontColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        if (activities
                                                .activitiesList[index]
                                                .totalSessionsDuration
                                                .inHours !=
                                            0)
                                          AutoSizeText(
                                            ' HR',
                                            minFontSize: 12,
                                            style: TextStyle(
                                              color: myThemeProvider.fontColor,
                                              letterSpacing: 2,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        if (activities
                                                    .activitiesList[index]
                                                    .totalSessionsDuration
                                                    .inHours ==
                                                0 &&
                                            activities
                                                    .activitiesList[index]
                                                    .totalSessionsDuration
                                                    .inMinutes !=
                                                0)
                                          AutoSizeText(
                                            activities.activitiesList[index]
                                                .totalSessionsDuration.inMinutes
                                                .toString(),
                                            minFontSize: 12,
                                            style: TextStyle(
                                              color: myThemeProvider.fontColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        if (activities
                                                    .activitiesList[index]
                                                    .totalSessionsDuration
                                                    .inHours ==
                                                0 &&
                                            activities
                                                    .activitiesList[index]
                                                    .totalSessionsDuration
                                                    .inMinutes !=
                                                0)
                                          AutoSizeText(
                                            ' MIN',
                                            minFontSize: 12,
                                            style: TextStyle(
                                              color: myThemeProvider.fontColor,
                                              letterSpacing: 2,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          child: EmojiWidget(
                            emoji: activities.activitiesList[index].emoji,
                            color: MyTheme
                                .colors[activities.activitiesList[index].color],
                            size: 50,
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
