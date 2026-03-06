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
    const primary = Color(0xFFC0392B);

    return Scaffold(
      appBar: AppBar(title: const Text('Painel Admin')),
      backgroundColor: const Color(0xFFF5F5F5),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ...cart.restaurants.map((r) {
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _RestaurantDetailPage(restaurant: r),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
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
                child: Row(
                  children: [
                    // Logo
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.shade100,
                      ),
                      child: r.logoUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                r.logoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.store, size: 24),
                              ),
                            )
                          : const Icon(Icons.store, size: 24),
                    ),
                    const SizedBox(width: 12),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            r.description,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              _StatusBadge(isOpen: r.isOpen),
                              if (r.isNew) ...[
                                const SizedBox(width: 5),
                                _Badge(
                                  label: 'Novo',
                                  bg: const Color(0xFFFFF3E0),
                                  fg: Colors.orange.shade800,
                                ),
                              ],
                              const SizedBox(width: 6),
                              Text(
                                '${r.ordersCount} pedidos',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 8),
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
    final address = TextEditingController();
    final selectedDays = ValueNotifier<List<int>>([1, 2, 3, 4, 5, 6, 7]);

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
                    hintText: 'Rua, número, bairro',
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
                  decoration: const InputDecoration(labelText: 'Logo (URL)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bannerUrl,
                  decoration: const InputDecoration(labelText: 'Banner (URL)'),
                ),
                const SizedBox(height: 20),
                Text(
                  'Dias de funcionamento',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                DaySelector(selectedDays: selectedDays),
                const SizedBox(height: 20),
                Text('Horário', style: Theme.of(context).textTheme.titleMedium),
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
                          address.text,
                          selectedDays.value,
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

// ─── TELA DE DETALHE ────────────────────────────────────────────────────────

class _RestaurantDetailPage extends StatelessWidget {
  final Restaurant restaurant;
  const _RestaurantDetailPage({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final r = context.watch<Cart>().restaurants.firstWhere(
      (x) => x.id == restaurant.id,
      orElse: () => restaurant,
    );
    const primary = Color(0xFFC0392B);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // ── HEADER ──
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF8B1a1a), Color(0xFFC0392B)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: r.logoUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    r.logoUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.store, size: 28),
                                  ),
                                )
                              : const Icon(Icons.store, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                r.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${r.isOpen ? "🟢 Aberto" : "🔴 Fechado"} • ${r.openTime} - ${r.closeTime}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // ── STATS ──
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      _StatBox(value: '${r.ordersCount}', label: 'Pedidos'),
                      const SizedBox(width: 10),
                      _StatBox(
                        value: 'R\$ ${r.totalRevenue.toStringAsFixed(0)}',
                        label: 'Faturamento',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ── AÇÕES ──
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      _ActionChip(
                        icon: Icons.edit,
                        label: 'Editar',
                        bg: Colors.grey.shade100,
                        fg: Colors.black87,
                        onTap: () => _showEditRestaurant(context, r),
                      ),
                      const SizedBox(width: 8),
                      _ActionChip(
                        icon: Icons.add_circle_outline,
                        label: 'Add item',
                        bg: const Color(0xFFE8F5E9),
                        fg: Colors.green.shade800,
                        onTap: () => _showAddItem(context, r),
                      ),
                      const SizedBox(width: 8),
                      _ActionChip(
                        icon: Icons.restart_alt,
                        label: 'Zerar',
                        bg: const Color(0xFFFFF3E0),
                        fg: Colors.orange.shade800,
                        onTap: () => _confirmResetStats(context, r),
                      ),
                      const SizedBox(width: 8),
                      _ActionChip(
                        icon: Icons.delete_outline,
                        label: 'Excluir',
                        bg: const Color(0xFFFDECEA),
                        fg: primary,
                        onTap: () => _confirmDelete(context, r),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ── MENU ──
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      Text(
                        'Menu (${r.menu.length} itens)',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                if (r.menu.isEmpty)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: const Center(
                      child: Text(
                        'Nenhum item cadastrado',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...r.menu.map(
                    (item) => Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                // Thumb
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey.shade100,
                                  ),
                                  child: item.imageUrl.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            item.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(
                                                  Icons.fastfood,
                                                  size: 20,
                                                ),
                                          ),
                                        )
                                      : const Icon(Icons.fastfood, size: 20),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        item.category,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'R\$ ${item.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _showEditItem(context, r, item),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Icons.edit, size: 14),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => context
                                      .read<Cart>()
                                      .removeMenuItem(r, item),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFDECEA),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                      size: 14,
                                      color: primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(height: 1, color: Colors.grey.shade100),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── WIDGETS AUXILIARES ─────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final bool isOpen;
  const _StatusBadge({required this.isOpen});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isOpen ? const Color(0xFFE8F8F0) : const Color(0xFFFDECEA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isOpen ? 'Aberto' : 'Fechado',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isOpen ? const Color(0xFF1a7a4a) : const Color(0xFFC0392B),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color bg, fg;
  const _Badge({required this.label, required this.bg, required this.fg});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value, label;
  const _StatBox({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFFC0392B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg, fg;
  final VoidCallback onTap;
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: fg),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DaySelector extends StatelessWidget {
  final ValueNotifier<List<int>> selectedDays;
  const DaySelector({super.key, required this.selectedDays});

  @override
  Widget build(BuildContext context) {
    const days = [
      {'label': 'S', 'full': 'Seg', 'value': 1},
      {'label': 'T', 'full': 'Ter', 'value': 2},
      {'label': 'Q', 'full': 'Qua', 'value': 3},
      {'label': 'Q', 'full': 'Qui', 'value': 4},
      {'label': 'S', 'full': 'Sex', 'value': 5},
      {'label': 'S', 'full': 'Sáb', 'value': 6},
      {'label': 'D', 'full': 'Dom', 'value': 7},
    ];

    return ValueListenableBuilder<List<int>>(
      valueListenable: selectedDays,
      builder: (_, selected, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days.map((day) {
            final val = day['value'] as int;
            final isSelected = selected.contains(val);
            return GestureDetector(
              onTap: () {
                final list = List<int>.from(selected);
                if (isSelected) {
                  list.remove(val);
                } else {
                  list.add(val);
                  list.sort();
                }
                selectedDays.value = list;
              },
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFC0392B)
                          : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        day['label'] as String,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day['full'] as String,
                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ─── DIALOGS ────────────────────────────────────────────────────────────────

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
  final address = TextEditingController(text: restaurant.address);
  final selectedDays = ValueNotifier<List<int>>(
    List<int>.from(restaurant.openDays),
  );

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
                decoration: const InputDecoration(labelText: 'Endereço'),
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
                decoration: const InputDecoration(labelText: 'Logo (URL)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bannerUrl,
                decoration: const InputDecoration(labelText: 'Banner (URL)'),
              ),
              const SizedBox(height: 20),
              Text(
                'Dias de funcionamento',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              DaySelector(selectedDays: selectedDays),
              const SizedBox(height: 20),
              Text('Horário', style: Theme.of(context).textTheme.titleMedium),
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
                          address: address.text,
                          openDays: selectedDays.value,
                          createdAt: restaurant.createdAt,
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
                'Editar item',
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

void _confirmResetStats(BuildContext context, Restaurant restaurant) {
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
              'Zerar estatísticas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Deseja zerar pedidos e faturamento de "${restaurant.name}"?\n\nEssa ação não pode ser desfeita.',
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: () {
                    context.read<Cart>().resetRestaurantStats(restaurant.id);
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Zerar'),
                ),
              ],
            ),
          ],
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
              'Tem certeza que deseja excluir "${restaurant.name}"?\n\nEssa ação não pode ser desfeita.',
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
