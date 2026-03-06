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
    return [_buildHome(context)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: _pages(context)[_currentIndex]),
      bottomNavigationBar: Consumer<Cart>(
        builder: (context, cart, _) {
          // Na aba Pedidos com itens: mostra barra da sacola + nav abaixo
          if (_currentIndex == 1 && cart.totalItems > 0) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Barra da sacola
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartPage()),
                      );
                    },
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC0392B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "Finalizar pedido",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Text(
                              "R\$ ${cart.totalAmount.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Nav bar normal
                BottomNavigationBar(
                  backgroundColor: Colors.white,
                  selectedItemColor: const Color(0xFF962d22),
                  unselectedItemColor: Colors.grey,
                  currentIndex: _currentIndex,
                  onTap: (i) {
                    if (i == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartPage()),
                      );
                    } else {
                      setState(() => _currentIndex = i);
                    }
                  },
                  type: BottomNavigationBarType.fixed,
                  iconSize: 24,
                  selectedFontSize: 11,
                  unselectedFontSize: 10,
                  selectedLabelStyle: const TextStyle(height: 1),
                  unselectedLabelStyle: const TextStyle(height: 1),
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Início',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.receipt_long),
                      label: 'Pedidos',
                    ),
                  ],
                ),
              ],
            );
          }

          // Demais casos: nav bar normal
          return BottomNavigationBar(
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF962d22),
            unselectedItemColor: Colors.grey,
            currentIndex: _currentIndex,
            onTap: (i) {
              if (i == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartPage()),
                );
              } else {
                setState(() => _currentIndex = i);
              }
            },
            type: BottomNavigationBarType.fixed,
            iconSize: 24,
            selectedFontSize: 11,
            unselectedFontSize: 10,
            selectedLabelStyle: const TextStyle(height: 1),
            unselectedLabelStyle: const TextStyle(height: 1),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long),
                label: 'Pedidos',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopItems(BuildContext context, dynamic cart) {
    // Coleta todos os itens com nome do restaurante
    final allItems = <Map<String, dynamic>>[];
    for (final r in cart.restaurants) {
      for (final item in r.menu as List) {
        if (item.category != 'Sabor' &&
            item.category != 'Borda' &&
            item.imageUrl.isNotEmpty) {
          allItems.add({'item': item, 'restaurantName': r.name as String});
        }
      }
    }

    // Ordena por ordersCount e pega top 10
    allItems.sort(
      (a, b) => (b['item'].ordersCount as int).compareTo(
        a['item'].ordersCount as int,
      ),
    );
    final topItems = allItems.take(10).toList();

    if (topItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        const Text(
          'Mais pedidos',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 158,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: topItems.length,
            itemBuilder: (context, index) {
              final entry = topItems[index];
              final item = entry['item'];
              final restaurantName = entry['restaurantName'] as String;
              return Container(
                width: 120,
                margin: EdgeInsets.only(
                  right: index < topItems.length - 1 ? 10 : 0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        item.imageUrl as String,
                        height: 90,
                        width: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 90,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.fastfood, size: 32),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (item.name as String),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'R\$ ${(item.price as double).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFC0392B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            restaurantName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
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

    // Ordena abertos: novos (0 pedidos) logo após o 1º, resto por pedidos
    final openList = restaurants.where((r) => r.isOpen).toList();
    final newOnes = openList.where((r) => r.isNew).toList();
    final veterans = openList.where((r) => !r.isNew).toList()
      ..sort((a, b) => b.ordersCount.compareTo(a.ordersCount));

    final openRestaurants = [
      if (veterans.isNotEmpty) veterans.first,
      ...newOnes,
      if (veterans.length > 1) ...veterans.sublist(1),
    ];

    // Fechados também por pedidos
    final closedRestaurants = restaurants.where((r) => !r.isOpen).toList()
      ..sort((a, b) => b.ordersCount.compareTo(a.ordersCount));

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
                  color: const Color(0xFFC0392B),
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
                                                    color: const Color(
                                                      0xFFC0392B,
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
                                                ? const Color(0xFFC0392B)
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
                                          ? const Color(0xFFC0392B)
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

                      // ================= MAIS PEDIDOS =================
                      _buildTopItems(context, cart),

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
                                child: Stack(
                                  children: [
                                    RestaurantCard(restaurant: restaurant),
                                    if (restaurant.isNew)
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFC0392B),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: const Text(
                                            'Novo',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
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
