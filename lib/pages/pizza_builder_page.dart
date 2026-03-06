import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/menu_item.dart';
import '../providers/cart.dart';

class PizzaBuilderPage extends StatefulWidget {
  final MenuItem pizzaBase;
  final int maxFlavors;

  const PizzaBuilderPage({
    super.key,
    required this.pizzaBase,
    required this.maxFlavors,
  });

  @override
  State<PizzaBuilderPage> createState() => _PizzaBuilderPageState();
}

class _PizzaBuilderPageState extends State<PizzaBuilderPage> {
  final List<MenuItem> selectedFlavors = [];
  MenuItem? selectedBorder;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<Cart>();
    final restaurant =
        cart.selectedRestaurant ??
        cart.restaurants.firstWhere((r) => r.menu.contains(widget.pizzaBase));
    final flavors = restaurant.menu
        .where((i) => i.category == 'Sabor')
        .toList();
    final borders = restaurant.menu
        .where((i) => i.category == 'Borda')
        .toList();
    final primary = const Color(0xFFC0392B);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // ── BANNER ──────────────────────────────────────────────
          Stack(
            children: [
              // Foto ou gradiente
              widget.pizzaBase.imageUrl.isNotEmpty
                  ? Image.network(
                      widget.pizzaBase.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _bannerGradient(),
                    )
                  : _bannerGradient(),

              // Overlay escuro
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.65),
                    ],
                  ),
                ),
              ),

              // Botão voltar
              Positioned(
                top: 0,
                left: 0,
                child: SafeArea(
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              // Título
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.pizzaBase.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Escolha até ${widget.maxFlavors} sabores',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        // Contador bolinhas
                        Row(
                          children: List.generate(widget.maxFlavors, (i) {
                            return Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i < selectedFlavors.length
                                    ? Colors.white
                                    : Colors.white30,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── LISTA ───────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // SABORES
                const Text(
                  'Sabores',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '${selectedFlavors.length} de ${widget.maxFlavors} selecionados',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Column(
                    children: flavors.asMap().entries.map((entry) {
                      final i = entry.key;
                      final f = entry.value;
                      final selected = selectedFlavors.contains(f);
                      final isLast = i == flavors.length - 1;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selected) {
                              selectedFlavors.remove(f);
                            } else if (selectedFlavors.length <
                                widget.maxFlavors) {
                              selectedFlavors.add(f);
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFFFFF5F5)
                                : Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: i == 0
                                  ? const Radius.circular(12)
                                  : Radius.zero,
                              bottom: isLast
                                  ? const Radius.circular(12)
                                  : Radius.zero,
                            ),
                            border: Border(
                              bottom: isLast
                                  ? BorderSide.none
                                  : BorderSide(color: Colors.grey.shade100),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                          child: Row(
                            children: [
                              // Check box
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: selected ? primary : Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: selected
                                        ? primary
                                        : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                ),
                                child: selected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 14,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                f.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? primary
                                      : const Color(0xFF1A1A2E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // BORDAS
                if (borders.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Borda',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Column(
                      children: borders.asMap().entries.map((entry) {
                        final i = entry.key;
                        final b = entry.value;
                        final selected = selectedBorder == b;
                        final isLast = i == borders.length - 1;

                        return GestureDetector(
                          onTap: () => setState(
                            () => selectedBorder = selected ? null : b,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFFFF5F5)
                                  : Colors.white,
                              borderRadius: BorderRadius.vertical(
                                top: i == 0
                                    ? const Radius.circular(12)
                                    : Radius.zero,
                                bottom: isLast
                                    ? const Radius.circular(12)
                                    : Radius.zero,
                              ),
                              border: Border(
                                bottom: isLast
                                    ? BorderSide.none
                                    : BorderSide(color: Colors.grey.shade100),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 13,
                            ),
                            child: Row(
                              children: [
                                // Radio
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(
                                      color: selected
                                          ? primary
                                          : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                  ),
                                  child: selected
                                      ? Center(
                                          child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: primary,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    b.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: selected
                                          ? primary
                                          : const Color(0xFF1A1A2E),
                                    ),
                                  ),
                                ),
                                Text(
                                  b.price > 0
                                      ? '+ R\$ ${b.price.toStringAsFixed(2)}'
                                      : 'Grátis',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: b.price > 0 ? primary : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],

                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),

      // ── BOTÃO FIXO ──────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: SafeArea(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: selectedFlavors.isEmpty
                ? null
                : () {
                    final cart = context.read<Cart>();
                    final flavorsText = selectedFlavors
                        .map((e) => e.name)
                        .join(' / ');
                    final borderText = selectedBorder != null
                        ? ' | Borda: ${selectedBorder!.name}'
                        : '';
                    final name =
                        '${widget.pizzaBase.name} ($flavorsText)$borderText';
                    final price =
                        widget.pizzaBase.price + (selectedBorder?.price ?? 0);

                    final item = MenuItem(
                      id: DateTime.now().toString(),
                      name: name,
                      description: '',
                      category: widget.pizzaBase.category,
                      price: price,
                      imageUrl: '',
                    );

                    final ok = cart.addItem(item, restaurant);
                    ScaffoldMessenger.of(context).clearSnackBars();

                    if (ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pizza adicionada ao carrinho'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Você só pode pedir de um restaurante por vez.',
                          ),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
            child: const Text(
              'Adicionar ao carrinho',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bannerGradient() {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B1a1a), Color(0xFFC0392B)],
        ),
      ),
      child: const Center(child: Text('🍕', style: TextStyle(fontSize: 72))),
    );
  }
}
