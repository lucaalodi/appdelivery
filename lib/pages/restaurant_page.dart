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
                    // ─── NOVO HEADER ───────────────────────────────────────
                    _RestaurantHeader(restaurant: restaurant),

                    // ───────────────────────────────────────────────────────
                    const SizedBox(height: 12),

                    // CATEGORIAS
                    if (categories.length > 1)
                      SizedBox(
                        height: 20,
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
                      padding: const EdgeInsets.all(6),
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
                            color: const Color(0xFFE77427),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  "Ver minha sacola",
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
                                  "R\$ ${cart.totalWithDelivery.toStringAsFixed(2)}",
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

// ════════════════════════════════════════════════════════════════
// HEADER COMPLETO DO RESTAURANTE
// ════════════════════════════════════════════════════════════════

// Altura total do header — ajuste aqui se quiser mais ou menos espaço
const double _headerHeight = 280.0;
const double _bannerHeight = 200.0;
const double _logoSize = 80.0;

class _RestaurantHeader extends StatelessWidget {
  final Restaurant restaurant;
  const _RestaurantHeader({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _headerHeight,
      width: double.infinity,
      child: Stack(
        children: [
          // ── BANNER ──────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _bannerHeight,
            child: restaurant.bannerUrl.isNotEmpty
                ? Image.network(
                    restaurant.bannerUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: Colors.grey.shade300),
                  )
                : Container(color: Colors.grey.shade300),
          ),

          // ── BOTÃO VOLTAR ─────────────────────────────────────────
          Positioned(
            top: 40,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // ── LOGO — independente, sempre na frente ────────────────
          // Mude o valor de 'top' para subir/descer a logo livremente
          Positioned(
            top: _bannerHeight - 40,
            right: 16,
            child: _LogoBadge(logoUrl: restaurant.logoUrl),
          ),

          // ── NOME DO RESTAURANTE — independente da logo ───────────
          // Mude o valor de 'top' para subir/descer o nome livremente
          Positioned(
            top: _bannerHeight + 16,
            left: 16,
            right: _logoSize + 24,
            child: Text(
              restaurant.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),

          // ── INFOS DA LOJA ────────────────────────────────────────
          Positioned(
            top: _bannerHeight + 52,
            left: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.info_outline, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  'infos da loja',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                Icon(Icons.chevron_right, size: 14, color: Colors.grey),
              ],
            ),
          ),

          // ── DIVIDER ──────────────────────────────────────────────
          Positioned(
            top: _bannerHeight + 80,
            left: 0,
            right: 0,
            child: const Divider(height: 1, thickness: 1),
          ),

          // ── LINHA DE ENTREGA ─────────────────────────────────────
          Positioned(
            top: _bannerHeight + 96,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoTile(
                  icon: Icons.directions_bike,
                  iconColor: const Color(0xFF50A773),
                  topLabel: 'ver taxas',
                  topLabelColor: const Color(0xFF50A773),
                  topLabelBold: true,
                  bottomLabel: 'entrega',
                ),
                _InfoTile(
                  icon: Icons.access_time,
                  topLabel: '60 - 90',
                  bottomLabel: 'minutos',
                ),
                _InfoTile(
                  icon: Icons.bookmark_border,
                  topLabel: 'R\$ 20',
                  bottomLabel: 'mínimo',
                ),
                _InfoTile(
                  icon: Icons.payment,
                  topLabel: '',
                  bottomLabel: 'pagamento',
                  extraIcon: Icons.home_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// BADGE DE RATING

// ────────────────────────────────────────────────────────────────

class _RatingBadge extends StatelessWidget {
  final double rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    // Não exibe se não houver rating
    if (rating <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFC107),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 2),
          const Icon(Icons.chevron_right, color: Colors.white, size: 16),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// LOGO COM SOMBRA
// ────────────────────────────────────────────────────────────────

class _LogoBadge extends StatelessWidget {
  final String logoUrl;
  const _LogoBadge({required this.logoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: logoUrl.isNotEmpty
            ? Image.network(logoUrl, fit: BoxFit.cover)
            : const Icon(Icons.store, size: 36, color: Colors.grey),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
// TILE DE INFO (entrega / tempo / mínimo / pagamento)
// ────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String topLabel;
  final Color? topLabelColor;
  final bool topLabelBold;
  final String bottomLabel;
  final IconData? extraIcon;

  const _InfoTile({
    required this.icon,
    this.iconColor = Colors.grey,
    required this.topLabel,
    this.topLabelColor,
    this.topLabelBold = false,
    required this.bottomLabel,
    this.extraIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Ícone(s)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: iconColor),
            if (extraIcon != null) ...[
              const SizedBox(width: 2),
              Icon(extraIcon, size: 18, color: Colors.grey),
            ],
          ],
        ),
        const SizedBox(height: 4),

        // Valor principal (ex: "ver taxas", "60 - 90", "R$ 20")
        if (topLabel.isNotEmpty)
          Text(
            topLabel,
            style: TextStyle(
              fontSize: 13,
              fontWeight: topLabelBold ? FontWeight.bold : FontWeight.normal,
              color: topLabelColor ?? const Color(0xFF1A1A2E),
            ),
          ),
        const SizedBox(height: 2),

        // Label inferior (ex: "entrega", "minutos", "mínimo")
        Text(
          bottomLabel,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
// BOTÃO ADICIONAR (sem alterações)
// ════════════════════════════════════════════════════════════════

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
