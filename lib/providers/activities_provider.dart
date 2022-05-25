import 'dart:developer';
import 'package:activitygo/providers/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'activity_provider.dart';

enum ActivitiesState { loading, done }

class Activities with ChangeNotifier {
  List<Activity> activitiesList = [];
  List<String> favorites = [];
  ActivitiesState activitiesState = ActivitiesState.loading;
  Activities() {
    fetchAndSetData();
  }
  addFavorites(String id) async {
    favorites.insert(0, id);
    Box<String> favoriteHive = await Hive.openBox<String>('favorite');
    favoriteHive.put(id, id);
    notifyListeners();
  }

  removeFavorites(String id) async {
    favorites.remove(id);
    Box<String> favoriteHive = await Hive.openBox<String>('favorite');
    favoriteHive.delete(id);
    notifyListeners();
  }

  Future<void> fetchAndSetData() async {
    log('Data: Init');
    Box<Activity> allActivities = await Hive.openBox<Activity>('activity',
        compactionStrategy: (entries, deletedEntries) {
      return deletedEntries > 5;
    });
    activitiesList.addAll(allActivities.values);
    activitiesList.sort((a, b) {
      var adate = a.lastUpdated;
      var bdate = b.lastUpdated;
      return adate.compareTo(bdate);
    });
    for (Activity activity in activitiesList) {
      Box<Session> allSessions =
          await Hive.openBox<Session>(activity.id + 'session',
              compactionStrategy: (entries, deletedEntries) {
        return deletedEntries > 15;
      });

      activity.sessions.addAll(allSessions.values);
      activity.sessions.sort((a, b) {
        var adate = a.start;
        var bdate = b.start;
        return adate.compareTo(bdate);
      });
    }
    Box<String> allFavorites = await Hive.openBox<String>('favorite',
        compactionStrategy: (entries, deletedEntries) {
      return deletedEntries > 15;
    });
    favorites.addAll(allFavorites.values);
    //
    // Activity test = Activity(title: 'test', color: 2, emoji: '😸');
    // addActivity(test);
    // for (int i = 0; i < 31; i++) {
    //   Session session = Session(
    //     activityId: test.id,
    //     duration: math.max(math.Random().nextInt(100), 1),
    //     start: DateTime.now().subtract(Duration(days: i)),
    //   );
    //   test.addSession(session);
    // }
    // activitiesList.add(test);
    //
    activitiesState = ActivitiesState.done;
    notifyListeners();
  }

  addActivity(Activity activity) async {
    activitiesList.insert(0, activity);
    Box<Activity> activityHive = await Hive.openBox<Activity>('activity');
    await activityHive.put(activity.id, activity);
    notifyListeners();
  }

  removeActivity(Activity activity) async {
    activitiesList.remove(activity);
    Box<Activity> activityHive = await Hive.openBox<Activity>('activity');
    await Hive.deleteBoxFromDisk(activity.id + 'session');
    await activityHive.delete(activity.id);
    removeFavorites(activity.id);
    notifyListeners();
  }
}
