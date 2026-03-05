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

    return Scaffold(
      appBar: AppBar(title: Text(widget.pizzaBase.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Escolha até ${widget.maxFlavors} sabores',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                children: [
                  const Text(
                    'Sabores',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ...flavors.map((f) {
                    final selected = selectedFlavors.contains(f);

                    return CheckboxListTile(
                      title: Text(f.name),
                      value: selected,
                      onChanged: (v) {
                        setState(() {
                          if (selected) {
                            selectedFlavors.remove(f);
                          } else if (selectedFlavors.length <
                              widget.maxFlavors) {
                            selectedFlavors.add(f);
                          }
                        });
                      },
                    );
                  }),

                  if (borders.isNotEmpty) ...[
                    const Divider(),
                    const Text(
                      'Borda',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...borders.map((b) {
                      return RadioListTile<MenuItem>(
                        title: Text(b.name),
                        subtitle: Text(
                          b.price > 0
                              ? '+ R\$ ${b.price.toStringAsFixed(2)}'
                              : 'Grátis',
                          style: TextStyle(
                            fontSize: 12,
                            color: b.price > 0
                                ? const Color(0xFFE77427)
                                : Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        value: b,
                        groupValue: selectedBorder,
                        onChanged: (v) {
                          setState(() {
                            selectedBorder = v;
                          });
                        },
                      );
                    }),
                  ],
                ],
              ),
            ),

            ElevatedButton(
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
              child: const Text('Adicionar ao carrinho'),
            ),
          ],
        ),
      ),
    );
  }
}
