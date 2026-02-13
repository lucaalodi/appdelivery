// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RestaurantAdapter extends TypeAdapter<Restaurant> {
  @override
  final int typeId = 2;

  @override
  Restaurant read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Restaurant(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      phone: fields[3] as String,
      logoUrl: fields[4] as String,
      bannerUrl: fields[5] as String,
      pixKey: fields[6] as String,
      menu: (fields[7] as List).cast<MenuItem>(),
      openTime: fields[8] as String,
      closeTime: fields[9] as String,
      deliveryFee: fields[10] as double,
      ordersCount: fields[11] as int,
      totalRevenue: fields[12] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Restaurant obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.logoUrl)
      ..writeByte(5)
      ..write(obj.bannerUrl)
      ..writeByte(6)
      ..write(obj.pixKey)
      ..writeByte(7)
      ..write(obj.menu)
      ..writeByte(8)
      ..write(obj.openTime)
      ..writeByte(9)
      ..write(obj.closeTime)
      ..writeByte(10)
      ..write(obj.deliveryFee)
      ..writeByte(11)
      ..write(obj.ordersCount)
      ..writeByte(12)
      ..write(obj.totalRevenue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RestaurantAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
