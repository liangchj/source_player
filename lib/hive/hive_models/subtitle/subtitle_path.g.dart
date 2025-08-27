// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtitle_path.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubtitlePathAdapter extends TypeAdapter<SubtitlePath> {
  @override
  final int typeId = 5;

  @override
  SubtitlePath read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubtitlePath(
      fields[0] as VideoResource,
      fields[1] as int,
      fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SubtitlePath obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.resource)
      ..writeByte(1)
      ..write(obj.episode)
      ..writeByte(2)
      ..write(obj.path);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubtitlePathAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
