import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:activitygo/providers/session_provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/activity_provider.dart';
import '../my_theme.dart';
import '../providers/my_theme_provider.dart';

class NewSessionPage extends StatefulWidget {
  static const String routeName = '/new-session';
  const NewSessionPage({Key? key}) : super(key: key);

  @override
  State<NewSessionPage> createState() => _NewSessionPageState();
}

enum TimerState { running, idle }

class _NewSessionPageState extends State<NewSessionPage> {
  late MyThemeProvider myThemeProvider;
  late Activity activity;
  late Session? session;
  bool isInit = false;
  late DateTime selectedDateTime;
  late Duration selectedDuration;
  bool showingTimer = false;
  TimerState timerState = TimerState.idle;
  bool goBack = false;
  Duration runningDuration = const Duration();
  Timer? timer;
  @override
  void didChangeDependencies() {
    if (!isInit) {
      setState(() {
        myThemeProvider = Provider.of<MyThemeProvider>(context, listen: false);
        Map<String, dynamic> args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
        activity = args['activity'] as Activity;
        session = args['session'] != null ? args['session'] as Session : null;
        selectedDateTime = session?.start ?? DateTime.now();
        selectedDuration = session?.duration != null
            ? Duration(minutes: session?.duration ?? 0)
            : const Duration();
        isInit = true;
      });
    }
    super.didChangeDependencies();
  }

  void startTimerCount() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
  }

  void addTime() {
    if (timerState == TimerState.running) {
      setState(() {
        final seconds = runningDuration.inSeconds + 1;
        runningDuration = Duration(seconds: seconds);
        selectedDuration = Duration(seconds: seconds);
      });
    } else {
      timer?.cancel();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectedDuration == const Duration(minutes: 0)) {
          return Future.delayed(Duration.zero).then((value) => true);
        }
        await showDialog(
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
                    "Hold up",
                    style: TextStyle(color: MyTheme.colors[activity.color]),
                  ),
                  content: Text(
                    "Do you want to go back?",
                    style: TextStyle(
                      color: myThemeProvider.fontColor,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          goBack = true;
                        });
                        Navigator.of(context).pop(Future.delayed(Duration.zero)
                            .then((value) => true));
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
                        Navigator.of(context).pop(Future.delayed(Duration.zero)
                            .then((value) => false));
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
        );
        if (goBack) {
          return Future.delayed(Duration.zero).then((value) => true);
        } else {
          return Future.delayed(Duration.zero).then((value) => false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: showingTimer
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      selectedDuration = runningDuration;
                      showingTimer = false;
                    });
                  },
                  icon: const Icon(Icons.arrow_back),
                )
              : null,
          actions: [
            TextButton(
              onPressed: () {
                if (!showingTimer) {
                  if (selectedDuration < const Duration(minutes: 1)) {
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
                                "Hold up",
                                style: TextStyle(
                                    color: MyTheme.colors[activity.color]),
                              ),
                              content: Text(
                                "Can't save session: duration is less than a minute",
                                style: TextStyle(
                                  color: myThemeProvider.fontColor,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'OK',
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
                    );
                    return;
                  }
                  if (session != null) {
                    session?.editSession(
                      duration: selectedDuration,
                      start: selectedDateTime,
                    );
                    Navigator.of(context).pop({
                      'new': false,
                      'session': session,
                    });
                  } else {
                    Session newSession = Session(
                      activityId: activity.id,
                      start: selectedDateTime,
                      duration: selectedDuration.inMinutes,
                    );
                    Navigator.of(context).pop({
                      'new': true,
                      'session': newSession,
                    });
                  }
                } else {
                  setState(() {
                    timer?.cancel();
                    showingTimer = false;
                  });
                }
              },
              child: Text(
                showingTimer ? 'Done ' : 'Save ',
                style: TextStyle(
                  fontSize: MyTheme.title2.fontSize,
                  color: Colors.blue,
                ),
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  showingTimer
                      ? 'Timer '
                      : (session != null ? 'Edit Session' : 'New Session'),
                  style: MyTheme.title1,
                ),
              ),
              const Divider(
                color: Colors.grey,
              ),
              if (!showingTimer)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GestureDetector(
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          builder: (context, child) {
                            return Theme(
                                data: ThemeData().copyWith(
                                  dialogBackgroundColor:
                                      myThemeProvider.bgColor,
                                  colorScheme: myThemeProvider.isDarkMode
                                      ? ColorScheme.dark(
                                          primary:
                                              MyTheme.colors[activity.color],
                                          onPrimary: myThemeProvider.fontColor,
                                          surface:
                                              MyTheme.colors[activity.color],
                                          onSurface: myThemeProvider.fontColor,
                                        )
                                      : ColorScheme.light(
                                          primary:
                                              MyTheme.colors[activity.color],
                                          onPrimary: myThemeProvider.fontColor,
                                          surface:
                                              MyTheme.colors[activity.color],
                                          onSurface: myThemeProvider.fontColor,
                                        ),
                                ),
                                child: child ?? const Text(''));
                          },
                          initialDate: session?.start ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now());
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (context, child) {
                          return Theme(
                              data: ThemeData().copyWith(
                                dialogBackgroundColor: myThemeProvider.bgColor,
                                colorScheme: myThemeProvider.isDarkMode
                                    ? ColorScheme.dark(
                                        primary: MyTheme.colors[activity.color],
                                        onPrimary: myThemeProvider.fontColor,
                                        onSurface: myThemeProvider.fontColor,
                                      )
                                    : ColorScheme.light(
                                        primary: MyTheme.colors[activity.color],
                                        onPrimary: myThemeProvider.fontColor,
                                        onSurface: myThemeProvider.fontColor,
                                      ),
                              ),
                              child: child ?? const Text(''));
                        },
                      );

                      if (pickedDate != null) {
                        setState(() {
                          if (pickedTime != null) {
                            selectedDateTime = pickedDate.add(Duration(
                                hours: pickedTime.hour,
                                minutes: pickedTime.minute));
                          } else {
                            selectedDateTime = pickedDate;
                          }
                        });
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: myThemeProvider.fontColor,
                          size: 30,
                        ),
                        AutoSizeText(
                          DateFormat(' MMMM, d-y h:mm a ')
                              .format(selectedDateTime),
                          maxLines: 2,
                          minFontSize: 16,
                          style: TextStyle(
                            color: myThemeProvider.fontColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Icon(
                          Icons.edit,
                          color: myThemeProvider.fontColor,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              Builder(
                builder: (context) {
                  return Theme(
                    data: ThemeData().copyWith(
                      //dialogBackgroundColor: myTheme.bgColor,
                      backgroundColor: myThemeProvider.fontColor,

                      dialogTheme: DialogTheme(
                          backgroundColor: MyTheme.colors[activity.color]),
                      colorScheme: myThemeProvider.isDarkMode
                          ? ColorScheme.dark(
                              secondary: MyTheme.colors[activity.color],
                            )
                          : ColorScheme.light(
                              secondary: MyTheme.colors[activity.color],
                            ),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(20),
                      child: showingTimer
                          ? DurationPicker(
                              key: Key(runningDuration.toString()),
                              duration: runningDuration,
                              baseUnit: (showingTimer)
                                  ? BaseUnit.second
                                  : BaseUnit.minute,
                              onChange: (val) {
                                if (!showingTimer) {
                                  setState(() => runningDuration = val);
                                }
                              },
                              snapToMins: 1.0,
                            )
                          : DurationPicker(
                              duration: selectedDuration,
                              baseUnit: (showingTimer)
                                  ? BaseUnit.second
                                  : BaseUnit.minute,
                              onChange: (val) {
                                if (!showingTimer) {
                                  setState(() => selectedDuration = val);
                                }
                              },
                              snapToMins: 1.0,
                            ),
                    ),
                  );
                },
              ),
              if (session == null && !showingTimer)
                Container(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showingTimer = true;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          MyTheme.colors[activity.color]),
                    ),
                    child: const Text(
                      'Start Timer instead',
                      style: MyTheme.title2,
                    ),
                  ),
                ),
              if (showingTimer)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            MyTheme.colors[activity.color]),
                      ),
                      onPressed: () {
                        if (timerState == TimerState.idle) {
                          setState(() {
                            timerState = TimerState.running;
                          });
                          startTimerCount();
                        } else {
                          timer?.cancel();
                          setState(() {
                            timerState = TimerState.idle;
                          });
                        }
                      },
                      child: Text(
                        timerState == TimerState.idle ? 'Start' : 'Pause',
                        style: MyTheme.title2,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            MyTheme.colors[activity.color]),
                      ),
                      onPressed: () {
                        setState(() {
                          timer?.cancel();
                          timerState = TimerState.idle;
                          selectedDuration = const Duration();
                          runningDuration = const Duration();
                        });
                      },
                      child: const Text(
                        'Reset',
                        style: MyTheme.title2,
                      ),
                    )
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
