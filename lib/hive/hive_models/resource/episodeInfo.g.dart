// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episodeInfo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EpisodeInfoAdapter extends TypeAdapter<EpisodeInfo> {
  @override
  final int typeId = 2;

  @override
  EpisodeInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EpisodeInfo(
      fields[0] as int,
      fields[1] == null ? '' : fields[1] as String,
      fields[2] as String,
      fields[3] as String?,
      fields[4] as int,
      fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, EpisodeInfo obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.episode)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.resourcePath)
      ..writeByte(3)
      ..write(obj.coverPath)
      ..writeByte(4)
      ..write(obj.totalDuration)
      ..writeByte(5)
      ..write(obj.positionInMilli);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EpisodeInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
