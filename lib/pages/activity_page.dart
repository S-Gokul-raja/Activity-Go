import 'dart:developer';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../providers/activity_provider.dart';
import '../widgets/duration_widget.dart';
import '../widgets/heatmap_widget.dart';
import '../my_theme.dart';
import '../providers/my_theme_provider.dart';
import '../widgets/areachart_widget.dart';
import 'new_activity_page.dart';
import 'new_session_page.dart';
import '../providers/session_provider.dart';

class ActivityPage extends StatefulWidget {
  static const String routeName = '/activity';
  const ActivityPage({Key? key}) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  late MyThemeProvider myThemeProvider;
  final pageController = PageController(initialPage: 0);

  bool isInit = false;
  @override
  void didChangeDependencies() {
    if (!isInit) {
      setState(() {
        myThemeProvider = Provider.of<MyThemeProvider>(context);
        isInit = true;
      });
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Activity activity = ModalRoute.of(context)?.settings.arguments as Activity;

    return ChangeNotifierProvider.value(
      value: activity,
      builder: (context, _) {
        double sessionHeight = 100;
        double offset = 5;
        Activity activity = Provider.of<Activity>(context);
        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    myThemeProvider.toggle();
                  },
                  child: Icon(
                    myThemeProvider.isDarkMode
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    color: myThemeProvider.fontColor,
                    size: 25,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, NewActivityPage.routeName,
                        arguments: <String, Activity?>{
                          "activity": activity,
                        }).then((result) {
                      if (result != null) {
                        Map<String, dynamic> newResult =
                            result as Map<String, dynamic>;
                        if (!newResult['new']) {
                          setState(() {});
                        }
                      }
                    });
                  },
                  child: Icon(
                    Icons.edit,
                    color: myThemeProvider.fontColor,
                    size: 25,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: AlertDialog(
                              elevation: 5,
                              backgroundColor: myThemeProvider.bgColor,
                              title: Text(
                                "Delete Activity",
                                style: TextStyle(
                                    color: MyTheme.colors[activity.color]),
                              ),
                              content: Text(
                                "Do you want to delete ${activity.title}?",
                                style: TextStyle(
                                  color: myThemeProvider.fontColor,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: Text(
                                    'OK',
                                    style: TextStyle(
                                      color: MyTheme.colors[activity.color],
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: Text(
                                    'CANCEL',
                                    style: TextStyle(
                                      color: MyTheme.colors[activity.color],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ).then((value) {
                      if (value != null) {
                        if (value) {
                          Navigator.of(context).pop({
                            'delete': true,
                            'new': false,
                            'activity': activity
                          });
                        } else {
                          Navigator.of(context).pop({
                            'delete': false,
                            'new': false,
                            'activity': activity
                          });
                        }
                      }
                    });
                  },
                  child: Icon(
                    Icons.delete,
                    color: myThemeProvider.fontColor,
                    size: 25,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(NewSessionPage.routeName,
                      arguments: {
                        'activity': activity,
                        'session': null
                      }).then((result) {
                    if (result != null) {
                      Map<String, dynamic> newResult =
                          result as Map<String, dynamic>;
                      if (newResult['new']) {
                        activity.addSession(newResult['session'] as Session);
                      }
                    }
                  });
                },
                child: Text(
                  'New Session + ',
                  style: TextStyle(
                    fontSize: MyTheme.title2.fontSize,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    activity.title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: MyTheme.title1.copyWith(
                      color: MyTheme.colors[activity.color],
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                ),
                if (activity.sessions.isNotEmpty)
                  SizedBox(
                    height: 350,
                    child: PageView(
                      controller: pageController,
                      children: [
                        HeatMapWidget(activity: activity),
                        const AreaChartWidget(),
                      ],
                    ),
                  ),
                if (activity.sessions.isNotEmpty)
                  DurationWidget(
                      color: MyTheme.colors[activity.color],
                      duration: activity.totalSessionsDuration),
                if (activity.sessions.isNotEmpty)
                  Container(
                    alignment: Alignment.center,
                    child: SmoothPageIndicator(
                      effect: ExpandingDotsEffect(
                        dotColor:
                            MyTheme.colors[activity.color].withOpacity(0.7),
                        activeDotColor: MyTheme.colors[activity.color],
                      ),
                      controller: pageController,
                      count: 2,
                      onDotClicked: (index) {
                        pageController.jumpToPage(index);
                      },
                    ),
                  ),
                if (activity.sessions.isNotEmpty)
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Your Sessions',
                      style: MyTheme.title2.copyWith(
                        color: myThemeProvider.fontColor,
                      ),
                    ),
                  ),
                if (activity.sessions.isEmpty)
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'No Sessions Yet',
                      style: MyTheme.title2.copyWith(
                        color: myThemeProvider.fontColor,
                      ),
                    ),
                  ),
                if (activity.sessions.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    padding:
                        const EdgeInsets.only(top: 20, bottom: 20, left: 20),
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: sessionHeight + 20 + offset),
                    itemCount: activity.sessions.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            height: sessionHeight,
                            margin: EdgeInsets.only(
                                top: offset, left: offset, right: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: MyTheme.colors[activity.color],
                              border: Border.all(
                                width: 2,
                                color: myThemeProvider.fontColor,
                              ),
                            ),
                          ),
                          Container(
                            height: sessionHeight,
                            margin: EdgeInsets.only(
                              right: offset + 20,
                              bottom: offset,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: myThemeProvider.bgColor,
                              border: Border.all(
                                width: 2,
                                color: myThemeProvider.fontColor,
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(10.0),
                              child: GestureDetector(
                                onTap: () {
                                  log('Edit Session');
                                  Navigator.pushNamed(
                                      context, NewSessionPage.routeName,
                                      arguments: {
                                        'session': activity.sessions[index],
                                        'activity': activity,
                                      }).then((_) {
                                    setState(() {});
                                  });
                                },
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: AutoSizeText(
                                            DateFormat('MMMM, d-y\nh:mm a')
                                                .format(activity
                                                    .sessions[index].start),
                                            maxLines: 3,
                                            minFontSize: 14,
                                            style: TextStyle(
                                              color: myThemeProvider.fontColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return BackdropFilter(
                                                  filter: ImageFilter.blur(
                                                      sigmaX: 5, sigmaY: 5),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25),
                                                    child: AlertDialog(
                                                      elevation: 5,
                                                      backgroundColor:
                                                          myThemeProvider
                                                              .bgColor,
                                                      title: Text(
                                                        "Delete Session",
                                                        style: TextStyle(
                                                            color: MyTheme
                                                                    .colors[
                                                                activity
                                                                    .color]),
                                                      ),
                                                      content: Text(
                                                        "Do you want to delete the session?",
                                                        style: TextStyle(
                                                          color: myThemeProvider
                                                              .fontColor,
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            activity.removeSession(
                                                                activity.sessions[
                                                                    index]);

                                                            Navigator.of(
                                                                    context)
                                                                .pop(true);
                                                          },
                                                          child: Text(
                                                            'OK',
                                                            style: TextStyle(
                                                              color: MyTheme
                                                                      .colors[
                                                                  activity
                                                                      .color],
                                                            ),
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(false);
                                                          },
                                                          child: Text(
                                                            'CANCEL',
                                                            style: TextStyle(
                                                              color: MyTheme
                                                                      .colors[
                                                                  activity
                                                                      .color],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        AutoSizeText(
                                          activity.sessions[index].duration
                                              .toString(),
                                          minFontSize: 16,
                                          style: TextStyle(
                                            color:
                                                MyTheme.colors[activity.color],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        AutoSizeText(
                                          ' MIN',
                                          minFontSize: 12,
                                          style: TextStyle(
                                            color:
                                                MyTheme.colors[activity.color],
                                            letterSpacing: 2,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
