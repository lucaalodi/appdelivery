import 'package:hive/hive.dart';
import 'menu_item.dart';
import '../services/time_service.dart';

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

  @HiveField(13)
  String address;

  // 1=Seg, 2=Ter, 3=Qua, 4=Qui, 5=Sex, 6=Sáb, 7=Dom
  @HiveField(14)
  List<int> openDays;

  @HiveField(15)
  DateTime? createdAt;

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
    this.address = '',
    List<int>? openDays,
    this.createdAt,
  }) : openDays = openDays ?? [1, 2, 3, 4, 5, 6, 7]; // padrão: todos os dias

  bool get isNew {
    if (createdAt == null) return false;
    final age = TimeService.now().difference(createdAt!).inDays;
    return age <= 5;
  }

  bool get isOpen {
    final now = TimeService.now();

    // Verifica dia da semana (DateTime: 1=Seg ... 7=Dom)
    if (!openDays.contains(now.weekday)) return false;

    final openParts = openTime.split(':');
    final closeParts = closeTime.split(':');

    final openHour = int.parse(openParts[0]);
    final openMin = int.parse(openParts[1]);
    final closeHour = int.parse(closeParts[0]);
    final closeMin = int.parse(closeParts[1]);

    final openToday = DateTime(now.year, now.month, now.day, openHour, openMin);
    var closeToday = DateTime(
      now.year,
      now.month,
      now.day,
      closeHour,
      closeMin,
    );

    if (closeToday.isBefore(openToday)) {
      closeToday = closeToday.add(const Duration(days: 1));

      if (now.isAfter(openToday) && now.isBefore(closeToday)) return true;

      // Verifica se hoje é um dia de funcionamento do dia anterior
      final yesterday = now.subtract(const Duration(days: 1));
      if (openDays.contains(yesterday.weekday)) {
        final openYesterday = openToday.subtract(const Duration(days: 1));
        final closeYesterday = closeToday.subtract(const Duration(days: 1));
        if (now.isAfter(openYesterday) && now.isBefore(closeYesterday))
          return true;
      }

      return false;
    }

    return now.isAfter(openToday) && now.isBefore(closeToday);
  }
}
