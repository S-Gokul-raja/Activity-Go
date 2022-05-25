import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'session_provider.dart';
part 'activity_provider.g.dart';

@HiveType(typeId: 1)
class Activity with ChangeNotifier {
  @HiveField(0)
  late String title;
  @HiveField(1)
  late String emoji;
  @HiveField(2)
  late String id;
  @HiveField(3)
  late DateTime created;
  @HiveField(4)
  late DateTime lastUpdated;
  List<Session> sessions = [];
  @HiveField(5)
  late int color;

  Duration get totalSessionsDuration {
    Duration total = const Duration();
    for (Session session in sessions) {
      total += Duration(minutes: session.duration);
    }
    return total;
  }

  Activity({required this.color, required this.title, required this.emoji}) {
    created = DateTime.now();
    id = "Activity:$title[${created.toIso8601String()}]";
    log('Activity: $id');
    lastUpdated = DateTime.now();
  }

  editActivity({int? color, String? emoji, String? title}) async {
    if (color != null) this.color = color;
    if (emoji != null) this.emoji = emoji;
    if (title != null) this.title = title;
    Box<Activity> activityHive = await Hive.openBox<Activity>('activity');
    await activityHive.put(id, this);
    notifyListeners();
  }

  addSession(Session session) async {
    sessions.insert(0, session);
    Box<Session> sessionHive =
        await Hive.openBox<Session>(session.activityId + 'session');
    await sessionHive.put(session.id, session);
    notifyListeners();
  }

  removeSession(Session session) async {
    sessions.remove(session);
    Box<Session> sessionHive =
        await Hive.openBox<Session>(session.activityId + 'session');
    await sessionHive.delete(session.id);
    notifyListeners();
  }

  editSession(
      {DateTime? start, required Duration duration, required Session session}) {
    session.editSession(start: start, duration: duration);
    notifyListeners();
  }
}
