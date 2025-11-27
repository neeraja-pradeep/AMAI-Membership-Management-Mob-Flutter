// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CacheEntryAdapter extends TypeAdapter<CacheEntry> {
  @override
  final int typeId = 1;

  @override
  CacheEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CacheEntry(
      key: fields[0] as String,
      data: fields[1] as dynamic,
      lastModified: fields[2] as String?,
      cachedAt: fields[3] as int,
      lastAccessed: fields[4] as int,
      accessCount: fields[5] as int,
      size: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CacheEntry obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.data)
      ..writeByte(2)
      ..write(obj.lastModified)
      ..writeByte(3)
      ..write(obj.cachedAt)
      ..writeByte(4)
      ..write(obj.lastAccessed)
      ..writeByte(5)
      ..write(obj.accessCount)
      ..writeByte(6)
      ..write(obj.size);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
