// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_provider.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionAdapter extends TypeAdapter<Session> {
  @override
  final int typeId = 2;

  @override
  Session read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Session(
      created: fields[0] as dynamic,
      id: fields[3] as dynamic,
      activityId: fields[4] as String,
      start: fields[2] as DateTime,
      duration: fields[5] as int,
    )..lastUpdated = fields[1] as DateTime;
  }

  @override
  void write(BinaryWriter writer, Session obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.created)
      ..writeByte(1)
      ..write(obj.lastUpdated)
      ..writeByte(2)
      ..write(obj.start)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.activityId)
      ..writeByte(5)
      ..write(obj.duration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
