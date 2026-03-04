import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../models/restaurant.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

int _orderCounter = 0;

String get orderNumber {
  _orderCounter++;
  return _orderCounter.toString().padLeft(3, '0');
}

class Cart extends ChangeNotifier {
  final Map<MenuItem, int> _items = {};
  late Box box;

  /// =======================
  /// RESTAURANTES
  /// =======================
  final List<Restaurant> restaurants = [];

  Restaurant? selectedRestaurant;

  void addRestaurant(
    String name,
    String phone,
    String pix,
    String description,
    String logoUrl,
    String bannerUrl,
    String openTime,
    String closeTime,
    double deliveryFee,
    String address, // NOVO
  ) {
    restaurants.add(
      Restaurant(
        id: DateTime.now().toString(),
        name: name,
        phone: phone,
        pixKey: pix,
        description: description,
        menu: [],
        openTime: openTime,
        closeTime: closeTime,
        deliveryFee: deliveryFee,
        ordersCount: 0,
        totalRevenue: 0,
        logoUrl: logoUrl,
        bannerUrl: bannerUrl,
        address: address, // NOVO
      ),
    );
    _saveData();
    notifyListeners();
  }

  void addMenuItem(Restaurant restaurant, MenuItem item) {
    final index = restaurants.indexWhere((r) => r.id == restaurant.id);
    if (index >= 0) {
      restaurants[index].menu.add(item);
      _saveData();
      notifyListeners();
    }
  }

  void updateRestaurant(Restaurant restaurant) {
    final index = restaurants.indexWhere((r) => r.id == restaurant.id);
    if (index >= 0) {
      restaurants[index] = restaurant;
      _saveData();
      notifyListeners();
    }
  }

  void removeRestaurant(String id) {
    restaurants.removeWhere((r) => r.id == id);
    _saveData();
    notifyListeners();
  }

  void removeMenuItem(Restaurant restaurant, MenuItem item) {
    restaurant.menu.removeWhere((i) => i.id == item.id);
    _saveData();
    notifyListeners();
  }

  Future<void> init() async {
    box = await Hive.openBox('delivery_db');
    _loadData();
  }

  void _loadData() {
    final data = box.get('restaurants');
    if (data != null) {
      restaurants.clear();
      for (final r in data) {
        restaurants.add(
          Restaurant(
            id: r['id'],
            name: r['name'],
            logoUrl: r['logoUrl'] ?? '',
            bannerUrl: r['bannerUrl'] ?? '',
            description: r['description'],
            phone: r['phone'],
            pixKey: r['pixKey'],
            openTime: r['openTime'],
            closeTime: r['closeTime'],
            deliveryFee: (r['deliveryFee'] ?? 0).toDouble(),
            ordersCount: r['ordersCount'] ?? 0,
            totalRevenue: (r['totalRevenue'] ?? 0).toDouble(),
            address:
                r['address'] ?? '', // NOVO — padrão vazio para dados antigos
            menu: List<MenuItem>.from(
              (r['menu'] as List).map(
                (m) => MenuItem(
                  id: m['id'],
                  name: m['name'],
                  description: m['description'],
                  category: m['category'],
                  price: m['price'],
                  imageUrl: m['imageUrl'] ?? '',
                ),
              ),
            ),
          ),
        );
      }
    }
    notifyListeners();
  }

  void _saveData() {
    final data = restaurants.map((r) {
      return {
        'id': r.id,
        'name': r.name,
        'description': r.description,
        'phone': r.phone,
        'pixKey': r.pixKey,
        'openTime': r.openTime,
        'closeTime': r.closeTime,
        'deliveryFee': r.deliveryFee,
        'ordersCount': r.ordersCount,
        'totalRevenue': r.totalRevenue,
        'logoUrl': r.logoUrl,
        'bannerUrl': r.bannerUrl,
        'address': r.address, // NOVO
        'menu': r.menu.map((m) {
          return {
            'id': m.id,
            'name': m.name,
            'description': m.description,
            'category': m.category,
            'price': m.price,
            'imageUrl': m.imageUrl,
          };
        }).toList(),
      };
    }).toList();
    box.put('restaurants', data);
  }

  /// =======================
  /// TAXA
  /// =======================
  bool isPickup = false;

  Map<MenuItem, int> get items => _items;

  int get totalItems {
    int total = 0;
    _items.forEach((item, quantity) {
      total += quantity;
    });
    return total;
  }

  double get totalAmount {
    double total = 0;
    _items.forEach((item, quantity) {
      total += item.price * quantity;
    });
    return total;
  }

  double get totalWithDelivery {
    if (isPickup) return totalAmount;
    final fee = selectedRestaurant?.deliveryFee ?? 0;
    return totalAmount + fee;
  }

  void setPickup(bool value) {
    isPickup = value;
    notifyListeners();
  }

  bool addItem(MenuItem item, Restaurant restaurant) {
    if (_items.isEmpty) {
      selectedRestaurant = restaurant;
    }
    if (selectedRestaurant!.id != restaurant.id) {
      return false;
    }
    if (_items.containsKey(item)) {
      _items[item] = _items[item]! + 1;
    } else {
      _items[item] = 1;
    }
    notifyListeners();
    return true;
  }

  void removeItem(MenuItem item) {
    if (!_items.containsKey(item)) return;
    if (_items[item]! > 1) {
      _items[item] = _items[item]! - 1;
    } else {
      _items.remove(item);
    }
    if (_items.isEmpty) {
      selectedRestaurant = null;
    }
    notifyListeners();
  }

  void removeSingleItem(String menuItemId) {
    try {
      final item = _items.keys.firstWhere(
        (element) => element.id == menuItemId,
      );
      if (_items[item]! > 1) {
        _items[item] = _items[item]! - 1;
      } else {
        _items.remove(item);
      }
      if (_items.isEmpty) {
        selectedRestaurant = null;
      }
      notifyListeners();
    } catch (e) {
      // item não encontrado
    }
  }

  void clear() {
    _items.clear();
    selectedRestaurant = null;
    notifyListeners();
  }

  void updateMenuItem(Restaurant restaurant, MenuItem item) {
    final rIndex = restaurants.indexWhere((r) => r.id == restaurant.id);
    if (rIndex >= 0) {
      final iIndex = restaurants[rIndex].menu.indexWhere(
        (i) => i.id == item.id,
      );
      if (iIndex >= 0) {
        restaurants[rIndex].menu[iIndex] = item;
        _saveData();
        notifyListeners();
      }
    }
  }

  /// =======================
  /// WHATSAPP MESSAGE
  /// =======================
  String generateOrderMessage({
    required String customerName,
    required String paymentMethod,
    String address = '',
    String notes = '',
    String change = '',
  }) {
    final orderNum = orderNumber;
    final buffer = StringBuffer();
    final time = DateFormat('HH:mm').format(DateTime.now());

    final restaurantName = selectedRestaurant?.name ?? 'Restaurante';
    final pixKey = selectedRestaurant?.pixKey ?? '';

    buffer.writeln('🛒 *Pedido #$orderNum - $time — $restaurantName*');
    buffer.writeln('');
    buffer.writeln('📦 *ITENS*');

    items.forEach((item, quantity) {
      String originalName = item.name.trim();
      String baseName = originalName;
      String? sabores;
      String? borda;

      if (baseName.contains('|')) {
        baseName = baseName.split('|').first.trim();
      }
      if (baseName.contains('(') && baseName.contains(')')) {
        final start = baseName.indexOf('(');
        final end = baseName.indexOf(')');
        sabores = baseName.substring(start + 1, end).trim();
        baseName = baseName.substring(0, start).trim();
      }
      if (originalName.contains('Borda:')) {
        final borderIndex = originalName.indexOf('Borda:');
        borda = originalName.substring(borderIndex + 6).trim();
      }

      final total = (item.price * quantity).toStringAsFixed(2);
      buffer.writeln('*${baseName.trim()}*');
      if (sabores != null && sabores.isNotEmpty) {
        buffer.writeln('   • Sabores: $sabores');
      }
      if (borda != null && borda.isNotEmpty) {
        buffer.writeln('   • Borda: $borda');
      }
      buffer.writeln('   • Valor: R\$ $total');
      buffer.writeln('');
    });

    buffer.writeln('');
    buffer.writeln('💰 *VALORES*');
    buffer.writeln('• Subtotal: R\$ ${totalAmount.toStringAsFixed(2)}');

    if (!isPickup) {
      final fee = selectedRestaurant?.deliveryFee ?? 0;
      buffer.writeln('• Taxa de entrega: R\$ ${fee.toStringAsFixed(2)}');
      buffer.writeln('• Total: R\$ ${totalWithDelivery.toStringAsFixed(2)}');
    } else {
      buffer.writeln('• Retirada no local');
      buffer.writeln('• Total: R\$ ${totalAmount.toStringAsFixed(2)}');
    }

    buffer.writeln('');
    buffer.writeln('👤 *CLIENTE*');
    buffer.writeln('• Nome: $customerName');
    buffer.writeln('');
    buffer.writeln('📍 *ENTREGA*');

    if (isPickup) {
      buffer.writeln('• Retirada no local');
    } else if (address.isNotEmpty) {
      buffer.writeln(
        address.startsWith('📍') ? address : '• Localização: $address',
      );
    }

    buffer.writeln('');
    buffer.writeln('💳 *PAGAMENTO*');
    buffer.writeln('• Pagamento: $paymentMethod');

    if (paymentMethod == 'Pix' && pixKey.isNotEmpty) {
      buffer.writeln('• Chave Pix: $pixKey');
    }
    if (paymentMethod == 'Dinheiro' && change.isNotEmpty) {
      buffer.writeln('• Troco para: R\$ $change');
    }
    if (notes.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('📝 *OBSERVAÇÕES*');
      buffer.writeln('• $notes');
    }

    buffer.writeln('');
    buffer.writeln('────────────────────────');
    buffer.writeln('⚠️ Confirmação do Restaurante');
    buffer.writeln('✅ CONFIRMADO ou ❌ RECUSADO');
    buffer.writeln('────────────────────────');
    buffer.writeln('📲 Enviado pelo app *1Rango*');

    return buffer.toString();
  }
}
