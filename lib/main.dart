import 'package:activitygo/pages/activity_page.dart';
import 'package:activitygo/pages/new_activity_page.dart';
import 'package:activitygo/pages/new_session_page.dart';
import 'package:activitygo/providers/activity_provider.dart';
import 'package:activitygo/providers/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'my_theme.dart';
import 'providers/activities_provider.dart';
import 'providers/my_theme_provider.dart';
import 'pages/activities_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(ActivityAdapter().typeId)) {
    Hive.registerAdapter(ActivityAdapter());
  }
  if (!Hive.isAdapterRegistered(SessionAdapter().typeId)) {
    Hive.registerAdapter(SessionAdapter());
  }
  runApp(const ActivityGo());
}

class ActivityGo extends StatelessWidget {
  const ActivityGo({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MyThemeProvider()),
        ChangeNotifierProvider(create: (context) => Activities()),
      ],
      builder: (context, _) {
        MyThemeProvider myThemeProvider = Provider.of<MyThemeProvider>(context);
        return MaterialApp(
          title: 'Activity Go',
          themeMode:
              myThemeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: MyTheme.lightTheme,
          darkTheme: MyTheme.darkTheme,
          debugShowCheckedModeBanner: false,
          home: const ActivitiesPage(),
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case NewActivityPage.routeName:
                return PageTransition(
                  child: const NewActivityPage(),
                  type: PageTransitionType.fade,
                  curve: Curves.easeOut,
                  settings: settings,
                );

              case ActivitiesPage.routeName:
                return PageTransition(
                  child: const ActivitiesPage(),
                  type: PageTransitionType.fade,
                  curve: Curves.easeOut,
                  settings: settings,
                );

              case ActivityPage.routeName:
                return PageTransition(
                  child: const ActivityPage(),
                  type: PageTransitionType.fade,
                  curve: Curves.easeOut,
                  settings: settings,
                );

              case NewSessionPage.routeName:
                return PageTransition(
                  child: const NewSessionPage(),
                  type: PageTransitionType.fade,
                  curve: Curves.easeOut,
                  settings: settings,
                );

              default:
                return PageTransition(
                  child: const ActivitiesPage(),
                  type: PageTransitionType.fade,
                  curve: Curves.easeOut,
                  settings: settings,
                );
            }
          },
        );
      },
    );
  }
}
