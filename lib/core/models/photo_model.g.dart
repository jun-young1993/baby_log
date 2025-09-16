// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PhotoModelAdapter extends TypeAdapter<PhotoModel> {
  @override
  final int typeId = 0;

  @override
  PhotoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PhotoModel(
      id: fields[0] as String,
      filePath: fields[1] as String,
      fileName: fields[2] as String,
      createdAt: fields[3] as DateTime,
      takenAt: fields[4] as DateTime?,
      caption: fields[5] as String?,
      tags: (fields[6] as List).cast<String>(),
      emotion: fields[7] as String?,
      isFirstMoment: fields[8] as bool,
      albumId: fields[9] as String?,
      latitude: fields[10] as double?,
      longitude: fields[11] as double?,
      fileSize: fields[12] as int,
      thumbnailPath: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PhotoModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.filePath)
      ..writeByte(2)
      ..write(obj.fileName)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.takenAt)
      ..writeByte(5)
      ..write(obj.caption)
      ..writeByte(6)
      ..write(obj.tags)
      ..writeByte(7)
      ..write(obj.emotion)
      ..writeByte(8)
      ..write(obj.isFirstMoment)
      ..writeByte(9)
      ..write(obj.albumId)
      ..writeByte(10)
      ..write(obj.latitude)
      ..writeByte(11)
      ..write(obj.longitude)
      ..writeByte(12)
      ..write(obj.fileSize)
      ..writeByte(13)
      ..write(obj.thumbnailPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhotoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
