// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'play_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayHistoryAdapter extends TypeAdapter<PlayHistory> {
  @override
  final int typeId = 1;

  @override
  PlayHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayHistory(
      fields[0] as VideoResource,
      (fields[1] as Map).cast<int, EpisodeInfo>(),
      fields[2] as int,
      fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PlayHistory obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.resource)
      ..writeByte(1)
      ..write(obj.episodeInfo)
      ..writeByte(2)
      ..write(obj.lastPlayEpisode)
      ..writeByte(3)
      ..write(obj.lastPlayTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
