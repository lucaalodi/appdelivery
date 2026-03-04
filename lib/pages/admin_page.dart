import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../models/restaurant.dart';
import '../models/menu_item.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<Cart>();

    return Scaffold(
      appBar: AppBar(title: const Text('Painel Admin')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Restaurantes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ...cart.restaurants.map((r) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          r.isOpen ? Icons.store : Icons.store_mall_directory,
                          color: r.isOpen ? Colors.green : Colors.red,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      r.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                        _showEditRestaurant(context, r),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _confirmDelete(context, r),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () => _showAddItem(context, r),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text('📞 ${r.phone}'),
                                  const SizedBox(width: 12),
                                  Text('🔑 ${r.pixKey}'),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('📝 ${r.description}'),
                              if (r.address.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text('📍 ${r.address}'),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text('📦 Pedidos: ${r.ordersCount}'),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '💰 R\$ ${r.totalRevenue.toStringAsFixed(2)}',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Divider(),
                    if (r.menu.isNotEmpty)
                      Column(
                        children: r.menu.map((item) {
                          return ListTile(
                            dense: true,
                            title: Text(item.name),
                            subtitle: Text(
                              '${item.category} • R\$ ${item.price.toStringAsFixed(2)}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _showEditItem(context, r, item),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    context.read<Cart>().removeMenuItem(
                                      r,
                                      item,
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('Nenhum item cadastrado'),
                      ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: () => _showAddRestaurant(context),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar restaurante'),
          ),
        ],
      ),
    );
  }

  void _showAddRestaurant(BuildContext context) {
    final name = TextEditingController();
    final phone = TextEditingController();
    final pix = TextEditingController();
    final description = TextEditingController();
    final logoUrl = TextEditingController();
    final bannerUrl = TextEditingController();
    final openTime = TextEditingController();
    final closeTime = TextEditingController();
    final deliveryFee = TextEditingController();
    final address = TextEditingController(); // NOVO

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Novo restaurante',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),

                Text(
                  'Informações básicas',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: description,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),

                Text(
                  'Localização',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: address,
                  decoration: const InputDecoration(
                    labelText: 'Endereço',
                    hintText: 'Rua, número, bairro, cidade',
                  ),
                ),
                const SizedBox(height: 20),

                Text('Contato', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                TextField(
                  controller: phone,
                  decoration: const InputDecoration(labelText: 'WhatsApp'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pix,
                  decoration: const InputDecoration(labelText: 'Chave Pix'),
                ),
                const SizedBox(height: 20),

                Text('Imagens', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                TextField(
                  controller: logoUrl,
                  decoration: const InputDecoration(
                    labelText: 'Logo (URL da imagem)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bannerUrl,
                  decoration: const InputDecoration(labelText: 'URL do Banner'),
                ),
                const SizedBox(height: 20),

                Text(
                  'Horário de funcionamento',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: openTime,
                        decoration: const InputDecoration(
                          labelText: 'Abre (18:00)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: closeTime,
                        decoration: const InputDecoration(
                          labelText: 'Fecha (23:00)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Text('Entrega', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                TextField(
                  controller: deliveryFee,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Taxa de entrega',
                    prefixText: 'R\$ ',
                  ),
                ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Provider.of<Cart>(context, listen: false).addRestaurant(
                          name.text,
                          phone.text,
                          pix.text,
                          description.text,
                          logoUrl.text,
                          bannerUrl.text,
                          openTime.text,
                          closeTime.text,
                          double.tryParse(deliveryFee.text) ?? 0,
                          address.text, // NOVO
                        );
                        Navigator.pop(dialogContext);
                      },
                      child: const Text('Salvar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showEditRestaurant(BuildContext context, Restaurant restaurant) {
  final name = TextEditingController(text: restaurant.name);
  final phone = TextEditingController(text: restaurant.phone);
  final pix = TextEditingController(text: restaurant.pixKey);
  final description = TextEditingController(text: restaurant.description);
  final logoUrl = TextEditingController(text: restaurant.logoUrl);
  final bannerUrl = TextEditingController(text: restaurant.bannerUrl);
  final openTime = TextEditingController(text: restaurant.openTime);
  final closeTime = TextEditingController(text: restaurant.closeTime);
  final deliveryFee = TextEditingController(
    text: restaurant.deliveryFee.toString(),
  );
  final address = TextEditingController(text: restaurant.address); // NOVO

  showDialog(
    context: context,
    builder: (dialogContext) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Editar restaurante',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),

              Text(
                'Informações básicas',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: description,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              Text(
                'Localização',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: address,
                decoration: const InputDecoration(
                  labelText: 'Endereço',
                  hintText: 'Rua, número, bairro, cidade',
                ),
              ),
              const SizedBox(height: 20),

              Text('Contato', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: phone,
                decoration: const InputDecoration(labelText: 'WhatsApp'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pix,
                decoration: const InputDecoration(labelText: 'Chave Pix'),
              ),
              const SizedBox(height: 20),

              Text('Imagens', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: logoUrl,
                decoration: const InputDecoration(
                  labelText: 'Logo (URL da imagem)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bannerUrl,
                decoration: const InputDecoration(labelText: 'URL do Banner'),
              ),
              const SizedBox(height: 20),

              Text(
                'Horário de funcionamento',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: openTime,
                      decoration: const InputDecoration(
                        labelText: 'Abre (18:00)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: closeTime,
                      decoration: const InputDecoration(
                        labelText: 'Fecha (23:00)',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text('Entrega', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: deliveryFee,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Taxa de entrega',
                  prefixText: 'R\$ ',
                ),
              ),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<Cart>(
                        context,
                        listen: false,
                      ).updateRestaurant(
                        Restaurant(
                          id: restaurant.id,
                          name: name.text,
                          description: description.text,
                          logoUrl: logoUrl.text,
                          bannerUrl: bannerUrl.text,
                          phone: phone.text,
                          pixKey: pix.text,
                          menu: restaurant.menu,
                          openTime: openTime.text,
                          closeTime: closeTime.text,
                          deliveryFee:
                              double.tryParse(deliveryFee.text) ??
                              restaurant.deliveryFee,
                          ordersCount: restaurant.ordersCount,
                          totalRevenue: restaurant.totalRevenue,
                          address: address.text, // NOVO
                        ),
                      );
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Salvar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void _showAddItem(BuildContext context, Restaurant restaurant) {
  final name = TextEditingController();
  final price = TextEditingController();
  final description = TextEditingController();
  final category = TextEditingController();
  final imageUrl = TextEditingController();

  showDialog(
    context: context,
    builder: (dialogContext) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Novo item - ${restaurant.name}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Nome do item'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: description,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 2,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: imageUrl,
                decoration: const InputDecoration(labelText: 'URL da imagem'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: category,
                decoration: const InputDecoration(
                  labelText: 'Categoria (Pizza, Lanche...)',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: price,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Preço'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<Cart>(context, listen: false).addMenuItem(
                        restaurant,
                        MenuItem(
                          id: DateTime.now().toString(),
                          name: name.text,
                          description: description.text,
                          category: category.text,
                          price: double.tryParse(price.text) ?? 0,
                          imageUrl: imageUrl.text,
                        ),
                      );
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Salvar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void _showEditItem(BuildContext context, Restaurant restaurant, MenuItem item) {
  final name = TextEditingController(text: item.name);
  final description = TextEditingController(text: item.description);
  final category = TextEditingController(text: item.category);
  final price = TextEditingController(text: item.price.toString());
  final imageUrl = TextEditingController(text: item.imageUrl);

  showDialog(
    context: context,
    builder: (dialogContext) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Editar item - ${restaurant.name}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: description,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 2,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: imageUrl,
                decoration: const InputDecoration(labelText: 'URL da imagem'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: category,
                decoration: const InputDecoration(labelText: 'Categoria'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: price,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Preço'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      context.read<Cart>().updateMenuItem(
                        restaurant,
                        MenuItem(
                          id: item.id,
                          name: name.text,
                          description: description.text,
                          category: category.text,
                          price: double.tryParse(price.text) ?? item.price,
                          imageUrl: imageUrl.text,
                        ),
                      );
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Salvar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void _confirmDelete(BuildContext context, Restaurant restaurant) {
  showDialog(
    context: context,
    builder: (dialogContext) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Excluir restaurante',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Tem certeza que deseja excluir "${restaurant.name}"?\n\nEssa ação não poderá ser desfeita.',
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    context.read<Cart>().removeRestaurant(restaurant.id);
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Excluir'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
