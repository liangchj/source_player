// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collect_resource.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CollectResourceAdapter extends TypeAdapter<CollectResource> {
  @override
  final int typeId = 3;

  @override
  CollectResource read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CollectResource(
      fields[0] as VideoResource,
      fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CollectResource obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.resource)
      ..writeByte(1)
      ..write(obj.time);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectResourceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
