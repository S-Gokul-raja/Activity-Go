// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_provider.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityAdapter extends TypeAdapter<Activity> {
  @override
  final int typeId = 1;

  @override
  Activity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Activity(
      color: fields[5] as int,
      title: fields[0] as String,
      emoji: fields[1] as String,
    )
      ..id = fields[2] as String
      ..created = fields[3] as DateTime
      ..lastUpdated = fields[4] as DateTime;
  }

  @override
  void write(BinaryWriter writer, Activity obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.emoji)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.created)
      ..writeByte(4)
      ..write(obj.lastUpdated)
      ..writeByte(5)
      ..write(obj.color);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
