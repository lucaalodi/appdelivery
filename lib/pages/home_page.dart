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
  String searchText = '';

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

    List restaurants = cart.restaurants.where((r) {
      final matchesCategory = selectedCategory == null
          ? true
          : r.description
                .toLowerCase()
                .split(',')
                .any((t) => t.trim() == selectedCategory!.toLowerCase());

      final matchesSearch = r.name.toLowerCase().contains(
        searchText.toLowerCase(),
      );

      return matchesCategory && matchesSearch;
    }).toList();

    final openRestaurants = restaurants.where((r) => r.isOpen).toList();
    final closedRestaurants = restaurants.where((r) => !r.isOpen).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: cart.restaurants.isEmpty
          ? const Center(child: Text('Nenhum restaurante cadastrado'))
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                // ================= HEADER SUPER COMPACTO =================
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  color: const Color.fromARGB(255, 231, 116, 39),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _handleSecretTap,
                        child: const Text(
                          '1Rango',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 1),
                      const Text(
                        'São Domingos - Santa Catarina',
                        style: TextStyle(fontSize: 13, color: Colors.white70),
                      ),
                      const SizedBox(height: 8),

                      SizedBox(
                        height: 36,
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchText = value;
                            });
                          },
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Buscar restaurante...',
                            hintStyle: const TextStyle(fontSize: 12),
                            prefixIcon: const Icon(Icons.search, size: 18),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
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
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final cat = categories[index];
                              final isSelected =
                                  selectedCategory == cat['name'];

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
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color.fromARGB(
                                                255,
                                                231,
                                                116,
                                                39,
                                              )
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
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Abertos agora',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Fechados',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                ),
              ],
            ),
    );
  }
}
