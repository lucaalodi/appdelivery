import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../widgets/restaurant_card.dart';
import 'restaurant_page.dart';
import 'admin_page.dart';
import 'cart_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tapCount = 0;
  int _currentIndex = 0;

  String? selectedCategory;

  final categories = const [
    {'icon': '🍔', 'name': 'Hamburguer'},
    {'icon': '🍕', 'name': 'Pizza'},
    {'icon': '🍟', 'name': 'Porções'},
    {'icon': '🥟', 'name': 'Pastel'},
    {'icon': '🌭', 'name': 'Lanches'},
    {'icon': '🥐', 'name': 'Padaria'},
  ];

  void _handleSecretTap() {
    _tapCount++;
    if (_tapCount == 5) {
      _tapCount = 0;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminPage()),
      );
    }
  }

  List<Widget> _pages(BuildContext context) {
    return [_buildHome(context), const CartPage()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(child: _pages(context)[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color.fromARGB(255, 187, 88, 31),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Pedidos',
          ),
        ],
      ),
    );
  }

  Widget _buildHome(BuildContext context) {
    final cart = context.watch<Cart>();
    List restaurants = cart.restaurants;

    if (selectedCategory != null) {
      restaurants = restaurants.where((r) {
        final tags = r.description.toLowerCase().split(',');
        return tags.any((t) => t.trim() == selectedCategory!.toLowerCase());
      }).toList();
    }

    final openRestaurants = restaurants.where((r) => r.isOpen).toList();
    final closedRestaurants = restaurants.where((r) => !r.isOpen).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        centerTitle: true,
        title: GestureDetector(
          onTap: _handleSecretTap,
          child: const Text(
            '1Rango',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
      body: cart.restaurants.isEmpty
          ? const Center(child: Text('Nenhum restaurante cadastrado'))
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                // ================= CATEGORIAS =================
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
                    ],
                  ),
                  child: SizedBox(
                    height: 85,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = selectedCategory == cat['name'];

                        return InkWell(
                          borderRadius: BorderRadius.circular(40),
                          onTap: () {
                            setState(() {
                              selectedCategory = isSelected
                                  ? null
                                  : cat['name'];
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color.fromARGB(255, 231, 116, 39)
                                      : Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  cat['icon']!,
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                cat['name']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ================= ABERTOS =================
                if (openRestaurants.isNotEmpty) ...[
                  const Text(
                    'Abertos agora',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  ...openRestaurants.map((restaurant) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RestaurantPage(restaurant: restaurant),
                            ),
                          );
                        },
                        child: RestaurantCard(restaurant: restaurant),
                      ),
                    );
                  }),
                ],

                // ================= FECHADOS =================
                if (closedRestaurants.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  const Text(
                    'Fechados',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  ...closedRestaurants.map((restaurant) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Opacity(
                        opacity: 0.5,
                        child: RestaurantCard(restaurant: restaurant),
                      ),
                    );
                  }),
                ],
              ],
            ),
    );
  }
}
