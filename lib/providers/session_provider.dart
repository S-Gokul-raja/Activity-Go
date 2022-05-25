import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
part 'session_provider.g.dart';

@HiveType(typeId: 2)
class Session with ChangeNotifier {
  @HiveField(0)
  late DateTime created;
  @HiveField(1)
  late DateTime lastUpdated;
  @HiveField(2)
  late DateTime start;
  @HiveField(3)
  late String id;
  @HiveField(4)
  late String activityId;
  @HiveField(5)
  late int duration;

  Session({
    created,
    id,
    required this.activityId,
    required this.start,
    required this.duration,
  }) {
    this.created = created ?? DateTime.now();
    this.id = id ?? "Session:$activityId[${this.created.toIso8601String()}]";
    log("Session: $id");
    lastUpdated = DateTime.now();
  }

  editSession({DateTime? start, required Duration duration}) async {
    this.duration = duration.inMinutes;
    if (start != null) this.start = start;
    Box<Session> sessionHive =
        await Hive.openBox<Session>(activityId + 'session');
    await sessionHive.put(id, this);
    notifyListeners();
  }
}
