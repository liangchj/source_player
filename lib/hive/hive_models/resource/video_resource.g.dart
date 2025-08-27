// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_resource.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VideoResourceAdapter extends TypeAdapter<VideoResource> {
  @override
  final int typeId = 0;

  @override
  VideoResource read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VideoResource(
      apiKey: fields[0] as String,
      spiGroupEnName: fields[1] as String,
      resourceId: fields[2] as String,
      resourceEnName: fields[3] as String,
      resourceName: fields[4] as String,
      resourceUrl: fields[5] as String,
      coverUrl: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, VideoResource obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.apiKey)
      ..writeByte(1)
      ..write(obj.spiGroupEnName)
      ..writeByte(2)
      ..write(obj.resourceId)
      ..writeByte(3)
      ..write(obj.resourceEnName)
      ..writeByte(4)
      ..write(obj.resourceName)
      ..writeByte(5)
      ..write(obj.resourceUrl)
      ..writeByte(6)
      ..write(obj.coverUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoResourceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
