// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'danmaku_paths.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DanmakuPathsAdapter extends TypeAdapter<DanmakuPaths> {
  @override
  final int typeId = 4;

  @override
  DanmakuPaths read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DanmakuPaths(
      fields[0] as VideoResource,
      fields[1] as int,
      fields[2] as String,
      fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DanmakuPaths obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.resource)
      ..writeByte(1)
      ..write(obj.episode)
      ..writeByte(2)
      ..write(obj.networkPath)
      ..writeByte(3)
      ..write(obj.localPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DanmakuPathsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
