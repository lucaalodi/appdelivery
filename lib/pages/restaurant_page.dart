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
  String selectedCategory = 'Todos';

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
      ...visibleMenu.map((item) => item.category).toSet(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: visibleMenu.isEmpty
          ? const Center(child: Text('Nenhum item disponível'))
          : Stack(
              children: [
                ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // HEADER
                    Stack(
                      children: [
                        SizedBox(
                          height: 190,
                          width: double.infinity,
                          child: restaurant.bannerUrl.isNotEmpty
                              ? Image.network(
                                  restaurant.bannerUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Container(color: Colors.grey.shade300),
                                )
                              : Container(color: Colors.grey.shade300),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 20, // 🔥 controla o tamanho do fade
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Color(0x55F7F7F7)],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 40,
                          left: 10,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 16,
                          right: 16,
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: restaurant.logoUrl.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: Image.network(
                                          restaurant.logoUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Icon(Icons.store),
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
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // CATEGORIAS
                    if (categories.length > 1)
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
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
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
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 8),

                    // MENU
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: selectedCategory == 'Todos'
                            ? visibleMenu
                                  .map((item) => item.category)
                                  .toSet()
                                  .map((category) {
                                    final items = visibleMenu
                                        .where((i) => i.category == category)
                                        .toList();

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 10,
                                            bottom: 4,
                                          ),
                                          child: Text(
                                            category,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        ...items.map(
                                          (item) => _buildMenuCard(
                                            item,
                                            cart,
                                            restaurant,
                                          ),
                                        ),
                                      ],
                                    );
                                  })
                                  .toList()
                            : visibleMenu
                                  .where(
                                    (item) => item.category == selectedCategory,
                                  )
                                  .map(
                                    (item) =>
                                        _buildMenuCard(item, cart, restaurant),
                                  )
                                  .toList(),
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),

                // SACOLA
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  bottom: cart.totalItems > 0 ? 0 : -100,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(6), // antes era 10
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CartPage()),
                          );
                        },
                        child: Container(
                          height: 44, // antes era 56
                          decoration: BoxDecoration(
                            color: const Color(0xFFE77427),
                            borderRadius: BorderRadius.circular(10), // antes 14
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 12), // antes 16

                              const Expanded(
                                child: Text(
                                  "Ver minha sacola",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14, // antes 16
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 12,
                                ), // antes 16
                                child: Text(
                                  "R\$ ${cart.totalWithDelivery.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14, // adicionado menor
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMenuCard(MenuItem item, Cart cart, Restaurant restaurant) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 55,
                  height: 55,
                  child: item.imageUrl.isNotEmpty
                      ? Image.network(item.imageUrl, fit: BoxFit.cover)
                      : Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.fastfood),
                        ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),

                    if (item.description.isNotEmpty)
                      Text(
                        item.description,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),

                    Text(
                      'R\$ ${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              AddButton(
                onTap: () {
                  if (item.category.toLowerCase().contains('pizza')) {
                    _openPizzaBuilder(context, item);
                  } else {
                    final ok = cart.addItem(item, restaurant);

                    if (!ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Você só pode pedir de um restaurante por vez.',
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),

        Divider(height: 0, thickness: 1, color: Colors.grey.shade300),
      ],
    );
  }

  void _openPizzaBuilder(BuildContext context, MenuItem item) {
    int maxFlavors = 2;

    final name = item.name.toLowerCase();

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

class AddButton extends StatefulWidget {
  final VoidCallback onTap;

  const AddButton({super.key, required this.onTap});

  @override
  State<AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<AddButton>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.92,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  Future<void> animate() async {
    await controller.reverse();
    await controller.forward();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: controller,
      child: GestureDetector(
        onTap: animate,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Adicionar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
