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
  final ScrollController _categoryScroll = ScrollController();
  final ValueNotifier<int> _categoryPage = ValueNotifier(0);
  final String _adminPassword = "912708";

  final categories = const [
    {'image': 'assets/categories/hamburguer.png', 'name': 'Hamburguer'},
    {'image': 'assets/categories/pizza.png', 'name': 'Pizza'},
    {'image': 'assets/categories/hot-dog.png', 'name': 'Hot-Dog'},
    {'image': 'assets/categories/porcoes.png', 'name': 'Porções'},
    {'image': 'assets/categories/pastel.png', 'name': 'Pastel'},
    {'image': 'assets/categories/combos.png', 'name': 'Combos'},
    {'image': 'assets/categories/bebidas.png', 'name': 'Bebidas'},
  ];

  void _handleSecretTap() {
    _tapCount++;
    if (_tapCount == 5) {
      _tapCount = 0;
      _showPasswordDialog();
    }
  }

  void _showPasswordDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Acesso Admin"),
        content: TextField(
          controller: controller,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Digite a senha"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text == _adminPassword) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminPage()),
                );
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Senha incorreta")),
                );
              }
            },
            child: const Text("Entrar"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _categoryScroll.dispose();
    _categoryPage.dispose();
    super.dispose();
  }

  List<Widget> _pages(BuildContext context) {
    return [_buildHome(context), const CartPage()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: _pages(context)[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color.fromARGB(255, 187, 88, 31),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        iconSize: 24,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        selectedLabelStyle: const TextStyle(height: 1),
        unselectedLabelStyle: const TextStyle(height: 1),
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
                // ================= HEADER =================
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
                      // ================= CATEGORIAS COM PONTOS =================
                      Column(
                        children: [
                          SizedBox(
                            height: 105,
                            child: ListView.builder(
                              controller: _categoryScroll,
                              padding: EdgeInsets.zero,
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                final cat = categories[index];
                                final isSelected =
                                    selectedCategory == cat['name'];

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedCategory = isSelected
                                          ? null
                                          : cat['name'] as String;
                                    });
                                  },
                                  child: Container(
                                    width: 78,
                                    margin: const EdgeInsets.only(right: 10),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 180,
                                          ),
                                          height: 64,
                                          width: 78,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color.fromARGB(
                                                    255,
                                                    255,
                                                    237,
                                                    224,
                                                  )
                                                : Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: isSelected
                                                ? Border.all(
                                                    color: const Color.fromARGB(
                                                      255,
                                                      231,
                                                      116,
                                                      39,
                                                    ),
                                                    width: 1.3,
                                                  )
                                                : null,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(6),
                                            child: Image.asset(
                                              cat['image'] as String,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          cat['name'] as String,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: isSelected
                                                ? const Color.fromARGB(
                                                    255,
                                                    231,
                                                    116,
                                                    39,
                                                  )
                                                : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // PONTOS INDICADORES — reativos e leves
                          const SizedBox(height: 8),
                          ValueListenableBuilder<int>(
                            valueListenable: _categoryPage,
                            builder: (_, page, __) {
                              // Atualiza o page ao scrollar
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (_categoryScroll.hasClients) {
                                  _categoryScroll.position.isScrollingNotifier
                                      .addListener(() {
                                        final max = _categoryScroll
                                            .position
                                            .maxScrollExtent;
                                        final cur = _categoryScroll.offset;
                                        if (max > 0) {
                                          _categoryPage.value = (cur / max * 2)
                                              .round();
                                        }
                                      });
                                }
                              });
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(3, (i) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: i == page
                                          ? const Color.fromARGB(
                                              255,
                                              231,
                                              116,
                                              39,
                                            )
                                          : Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                        ],
                      ),

                      // ================= ABERTOS =================
                      if (openRestaurants.isNotEmpty) ...[
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Abertos agora',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...openRestaurants.map((restaurant) {
                          return Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RestaurantPage(
                                        restaurant: restaurant,
                                      ),
                                    ),
                                  );
                                },
                                child: RestaurantCard(restaurant: restaurant),
                              ),
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: Colors.grey.withOpacity(0.15),
                              ),
                            ],
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
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
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
