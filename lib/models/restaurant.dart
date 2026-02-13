import 'package:hive/hive.dart';
import 'menu_item.dart';

part 'restaurant.g.dart';

@HiveType(typeId: 2)
class Restaurant extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  String phone;

  @HiveField(4)
  String logoUrl;

  @HiveField(5)
  String bannerUrl;

  @HiveField(6)
  String pixKey;

  @HiveField(7)
  List<MenuItem> menu;

  @HiveField(8)
  String openTime;

  @HiveField(9)
  String closeTime;

  @HiveField(10)
  double deliveryFee;

  @HiveField(11)
  int ordersCount;

  @HiveField(12)
  double totalRevenue;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.phone,
    required this.logoUrl,
    required this.bannerUrl,
    required this.pixKey,
    required this.menu,
    required this.openTime,
    required this.closeTime,
    required this.deliveryFee,
    required this.ordersCount,
    required this.totalRevenue,
  });

  bool get isOpen {
    final now = DateTime.now();

    final openParts = openTime.split(':');
    final closeParts = closeTime.split(':');

    final open = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(openParts[0]),
      int.parse(openParts[1]),
    );

    final close = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(closeParts[0]),
      int.parse(closeParts[1]),
    );

    return now.isAfter(open) && now.isBefore(close);
  }
}
