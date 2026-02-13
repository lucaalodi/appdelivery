import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/restaurant.dart';
import '../models/menu_item.dart';
import '../providers/cart.dart';
import 'cart_page.dart';
import 'pizza_builder_page.dart';

class RestaurantPage extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantPage({super.key, required this.restaurant});

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  String? selectedCategory;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cart = context.read<Cart>();

      if (cart.selectedRestaurant != null &&
          cart.selectedRestaurant!.id != widget.restaurant.id &&
          cart.items.isNotEmpty) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Finalize ou limpe o carrinho antes de mudar de restaurante.',
            ),
          ),
        );
      } else {
        cart.selectedRestaurant ??= widget.restaurant;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<Cart>();
    final restaurant = widget.restaurant;

    final visibleMenu = restaurant.menu.where((i) {
      return i.category != 'Sabor' && i.category != 'Borda';
    }).toList();

    final categories = [
      'Todos',
      ...visibleMenu.map((item) => item.category).toSet().toList(),
    ];

    if (selectedCategory == null && categories.isNotEmpty) {
      selectedCategory = 'Todos';
    }

    return Scaffold(
      body: visibleMenu.isEmpty
          ? const Center(child: Text('Nenhum item disponível'))
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                // ================= HEADER =================
                Stack(
                  children: [
                    SizedBox(
                      height: 190,
                      width: double.infinity,
                      child: restaurant.bannerUrl.isNotEmpty
                          ? Image.network(
                              restaurant.bannerUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return Container(color: Colors.grey.shade300);
                              },
                            )
                          : Container(color: Colors.grey.shade300),
                    ),
                    Container(
                      height: 190,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      left: 10,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 16,
                      right: 16,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 6),
                              ],
                            ),
                            child: restaurant.logoUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.network(
                                      restaurant.logoUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(Icons.store, size: 40),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              restaurant.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.shopping_cart,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const CartPage(),
                                    ),
                                  );
                                },
                              ),
                              if (cart.totalItems > 0)
                                Positioned(
                                  right: 6,
                                  top: 6,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      cart.totalItems.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ================= TABS =================
                if (categories.isNotEmpty)
                  SizedBox(
                    height: 45,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = selectedCategory == category;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              category,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 12),

                // ================= MENU FILTRADO =================
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: visibleMenu
                        .where(
                          (item) => selectedCategory == 'Todos'
                              ? true
                              : item.category == selectedCategory,
                        )
                        .map((item) {
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                if (item.category.toLowerCase().contains(
                                  'pizza',
                                )) {
                                  _openPizzaBuilder(context, item);
                                } else {
                                  final ok = cart.addItem(item, restaurant);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        ok
                                            ? 'Adicionado ao carrinho'
                                            : 'Você só pode pedir de um restaurante por vez.',
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: item.imageUrl.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                item.imageUrl,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.fastfood,
                                              size: 34,
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (item.description.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 4,
                                              ),
                                              child: Text(
                                                item.description,
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'R\$ ${item.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.add_circle),
                                  ],
                                ),
                              ),
                            ),
                          );
                        })
                        .toList(),
                  ),
                ),
              ],
            ),
    );
  }

  void _openPizzaBuilder(BuildContext context, MenuItem item) {
    final name = item.name.toLowerCase();
    int maxFlavors = 2;

    if (name.contains('media') || name.contains('média')) maxFlavors = 3;
    if (name.contains('grande')) maxFlavors = 4;
    if (name.contains('familia') || name.contains('fam')) maxFlavors = 5;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PizzaBuilderPage(pizzaBase: item, maxFlavors: maxFlavors),
      ),
    );
  }
}
