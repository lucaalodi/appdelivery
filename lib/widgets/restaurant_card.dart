import 'package:flutter/material.dart';
import '../models/restaurant.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantCard({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        children: [
          // LOGO
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade200,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: restaurant.logoUrl.isNotEmpty
                  ? Image.network(
                      restaurant.logoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.store, size: 30),
                    )
                  : const Icon(Icons.store, size: 30),
            ),
          ),

          const SizedBox(width: 12),

          // INFOS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  restaurant.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  restaurant.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    Icon(
                      Icons.delivery_dining,
                      size: 15,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      restaurant.deliveryFee == 0
                          ? 'Entrega grátis'
                          : 'Taxa R\$ ${restaurant.deliveryFee.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // STATUS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: restaurant.isOpen ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              restaurant.isOpen ? 'Aberto' : 'Fechado',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
