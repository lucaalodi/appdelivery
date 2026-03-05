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
                        height: 32,
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

                // BARRA SUPERIOR COM GRADIENTE — fixa, sempre visível
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.75),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                            color: const Color(0xFFC0392B),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 7),
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

              const SizedBox(width: 7),

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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
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

const double _headerHeight = 350.0;
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

          // ── LOGO — independente, sempre na frente ────────────────
          Positioned(
            top: _bannerHeight - 40,
            right: 16,
            child: _LogoBadge(logoUrl: restaurant.logoUrl),
          ),

          // ── AVALIAÇÃO — centralizada com a logo ─────────────────
          Positioned(
            top: _bannerHeight - 40 + _logoSize + 6,
            right: 16,
            width: _logoSize,
            child: Center(child: _StarRating(rating: 4.8)),
          ),

          // ── NOME DO RESTAURANTE — independente da logo ───────────
          Positioned(
            top: _bannerHeight + 6,
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

          // ── ENDEREÇO — abaixo do nome ────────────────────────────
          if (restaurant.address.isNotEmpty)
            Positioned(
              top: _bannerHeight + 52,
              left: 16,
              right: _logoSize + 24,
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      restaurant.address,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // ── INFOS DA LOJA ────────────────────────────────────────
          Positioned(
            top: _bannerHeight + 72,
            left: 16,
            child: GestureDetector(
              onTap: () => _showInfosDialog(context, restaurant),
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
          ),

          // ── DIVIDER ──────────────────────────────────────────────
          Positioned(
            top: _bannerHeight + 100,
            left: 0,
            right: 0,
            child: Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.shade200,
            ),
          ),

          // ── LINHA DE INFOS ────────────────────────────────────────
          Positioned(
            top: _bannerHeight + 108,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _InfoTileHorizontal(
                  icon: Icons.directions_bike,
                  label: restaurant.deliveryFee == 0
                      ? 'Grátis'
                      : 'R\$ ${restaurant.deliveryFee.toStringAsFixed(2)}',
                  sublabel: 'Taxa',
                ),
                const SizedBox(width: 7),
                _InfoTileHorizontal(
                  icon: Icons.access_time,
                  label: '${restaurant.openTime} - ${restaurant.closeTime}',
                  sublabel: 'Expediente',
                ),
                const SizedBox(width: 7),
                _InfoTileHorizontal(
                  icon: Icons.star,
                  label: '5.0',
                  sublabel: 'Avaliação',
                ),
                const SizedBox(width: 7),
                _InfoTileIcons(
                  icons: [
                    Icons.credit_card_outlined,
                    Icons.pix,
                    Icons.attach_money,
                  ],
                  sublabel: 'Pagamento',
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
// AVALIAÇÃO COM ESTRELAS
// ────────────────────────────────────────────────────────────────

class _StarRating extends StatelessWidget {
  final double rating;
  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return const Icon(Icons.star, color: Color(0xFFFFC107), size: 16);
      }),
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
// TILE HORIZONTAL — ícone + valor lado a lado
// ────────────────────────────────────────────────────────────────

class _InfoTileHorizontal extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;

  const _InfoTileHorizontal({
    required this.icon,
    required this.label,
    required this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.grey),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          sublabel,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────
// TILE DE ÍCONES — múltiplos ícones + label embaixo
// ────────────────────────────────────────────────────────────────

class _InfoTileIcons extends StatelessWidget {
  final List<IconData> icons;
  final String sublabel;

  const _InfoTileIcons({required this.icons, required this.sublabel});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: icons
              .map(
                (icon) => Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(icon, size: 18, color: Colors.grey),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 2),
        Text(
          sublabel,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
// MODAL DE INFOS DA LOJA
// ════════════════════════════════════════════════════════════════

void _showInfosDialog(BuildContext context, Restaurant restaurant) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            restaurant.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          if (restaurant.address.isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    restaurant.address,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          Row(
            children: [
              const Icon(
                Icons.access_time_outlined,
                size: 18,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                'Abre às ${restaurant.openTime} • Fecha às ${restaurant.closeTime}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text(restaurant.phone, style: const TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    ),
  );
}

// ════════════════════════════════════════════════════════════════
// BOTÃO ADICIONAR
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
