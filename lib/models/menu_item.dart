import 'package:hive/hive.dart';

part 'menu_item.g.dart';

@HiveType(typeId: 1)
class MenuItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  String category;

  @HiveField(4)
  double price;

  @HiveField(5)
  String imageUrl;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
  });
}
