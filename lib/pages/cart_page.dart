import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/cart.dart';

class CartPage extends StatefulWidget {
  final bool showAppBar;
  const CartPage({super.key, this.showAppBar = true});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _pageController = PageController();
  int step = 0;

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _changeController = TextEditingController();

  String paymentMethod = 'Dinheiro';

  void next(Cart cart) {
    // Validação por step
    if (step == 1) {
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Informe seu nome"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (!cart.isPickup && _addressController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Informe o endereço para entrega"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    if (step < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
      setState(() => step++);
    }
  }

  void back() {
    if (step > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
      setState(() => step--);
    }
  }

  Future<void> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final url =
        'https://maps.google.com/?q=${position.latitude.toStringAsFixed(5)},${position.longitude.toStringAsFixed(5)}';

    setState(() {
      _addressController.text = url;
    });
  }

  Future<void> sendOrderToWhatsApp({
    required BuildContext context,
    required String phone,
    required String message,
  }) async {
    final encodedMessage = Uri.encodeComponent(message);
    final url = Uri.parse('https://wa.me/$phone?text=$encodedMessage');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<Cart>();

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Finalizar pedido'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (step > 0) {
                    back();
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            )
          : null,
      body: cart.items.isEmpty
          ? const Center(child: Text('Carrinho vazio'))
          : Column(
              children: [
                LinearProgressIndicator(
                  value: (step + 1) / 3,
                  color: Theme.of(context).colorScheme.primary,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.4),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      stepCart(cart),
                      stepData(cart),
                      stepPayment(cart),
                    ],
                  ),
                ),
                if (widget.showAppBar) footer(cart),
              ],
            ),
    );
  }

  Widget stepCart(Cart cart) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seu pedido',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: cart.items.entries.map((e) {
                final item = e.key;
                final qty = e.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'R\$ ${item.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => cart.removeItem(item),
                            ),
                            Text(
                              qty.toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () =>
                                  cart.addItem(item, cart.selectedRestaurant!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Text('Subtotal', style: TextStyle(fontSize: 14)),
                const Spacer(),
                Text(
                  'R\$ ${cart.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget stepData(Cart cart) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6),
              ],
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text(
                      'Dados do cliente',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Seu nome',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 3),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.local_shipping),
                    SizedBox(width: 6),
                    Text(
                      'Entrega',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Retirar no local'),
                  subtitle: const Text('Sem taxa de entrega'),
                  value: cart.isPickup,
                  onChanged: (v) {
                    cart.setPickup(v);
                    if (v) _addressController.clear();
                  },
                ),
                if (!cart.isPickup) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Endereço de entrega',
                      hintText: 'Rua, bairro, número...',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Colors.grey.shade300,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'OU',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: getLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        foregroundColor: Colors.black87,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        minimumSize: const Size(0, 36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      icon: const Icon(Icons.my_location, size: 18),
                      label: const Text(
                        'Usar minha localização',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6),
              ],
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.note_alt),
                    SizedBox(width: 8),
                    Text(
                      'Observações',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  maxLines: 4,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: 'Ex: sem cebola, entregar no portão...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget stepPayment(Cart cart) {
    final deliveryFee = cart.isPickup
        ? 0
        : (cart.totalWithDelivery - cart.totalAmount);

    Widget paymentOption({required String title, required IconData icon}) {
      final isSelected = paymentMethod == title;
      return GestureDetector(
        onTap: () => setState(() => paymentMethod = title),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minHeight: 34),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.secondary
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListView(
        children: [
          const Text(
            'Forma de pagamento',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          paymentOption(title: 'Dinheiro', icon: Icons.payments),
          paymentOption(title: 'Pix', icon: Icons.qr_code),
          paymentOption(title: 'Cartão', icon: Icons.credit_card),
          if (paymentMethod == 'Dinheiro') ...[
            const SizedBox(height: 12),
            TextField(
              controller: _changeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Troco para quanto?',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumo do pedido',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text('Subtotal: R\$ ${cart.totalAmount.toStringAsFixed(2)}'),
                if (!cart.isPickup)
                  Text('Entrega: R\$ ${deliveryFee.toStringAsFixed(2)}'),
                const Divider(height: 18),
                Text(
                  'Total: R\$ ${cart.totalWithDelivery.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget footer(Cart cart) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: SafeArea(
        child: Row(
          children: [
            TextButton(
              onPressed: () {
                if (step == 0) {
                  Navigator.pop(context);
                } else {
                  back();
                }
              },
              child: Text(step == 0 ? 'Início' : 'Voltar'),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: step == 2
                    ? Theme.of(context).colorScheme.primary
                    : null,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (step == 2) {
                  finishOrder(cart);
                } else {
                  next(cart);
                }
              },
              child: Text(
                step == 2 ? 'Confirmar pedido' : 'Próximo',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> finishOrder(Cart cart) async {
    final restaurant = cart.selectedRestaurant!;
    final message = cart.generateOrderMessage(
      customerName: _nameController.text.isEmpty
          ? 'Não informado'
          : _nameController.text,
      paymentMethod: paymentMethod,
      address: _addressController.text,
      notes: _notesController.text,
      change: _changeController.text,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmar pedido"),
          content: const Text(
            'Seu pedido será enviado para o WhatsApp do restaurante.\n\n'
            'Na próxima tela, toque em "Enviar" para finalizar.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE77427),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Enviar pedido"),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    restaurant.ordersCount++;
    restaurant.totalRevenue += cart.totalWithDelivery;

    // Incrementa contador de cada item pedido
    cart.incrementItemOrders();

    cart.updateRestaurant(restaurant);

    await sendOrderToWhatsApp(
      context: context,
      phone: restaurant.phone,
      message: message,
    );

    cart.clear();
    _nameController.clear();
    _addressController.clear();
    _notesController.clear();
    _changeController.clear();
    _pageController.jumpToPage(0);
  }
}
