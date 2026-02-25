import 'package:flutter/material.dart';
import '../models/restaurant.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantCard({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          // LOGO
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: restaurant.logoUrl.isNotEmpty
                  ? Image.network(
                      restaurant.logoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.store, size: 26),
                    )
                  : const Icon(Icons.store, size: 26),
            ),
          ),

          const SizedBox(width: 10), // 🔥 antes 14
          // INFOS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // 🔥 importante
              children: [
                Text(
                  restaurant.name,
                  style: const TextStyle(
                    fontSize: 15, // 🔥 antes 16
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 2), // 🔥 antes 4

                Text(
                  restaurant.description,
                  maxLines: 1, // 🔥 antes 2
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12, // 🔥 antes 13
                  ),
                ),

                const SizedBox(height: 3), // 🔥 antes 6

                Row(
                  children: [
                    Icon(
                      Icons.delivery_dining,
                      size: 14, // 🔥 antes 16
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      restaurant.deliveryFee == 0
                          ? 'Entrega grátis'
                          : 'Taxa R\$ ${restaurant.deliveryFee.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 11, // 🔥 antes 12
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // STATUS (menor)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 7, // 🔥 antes 8
              vertical: 3, // 🔥 antes 4
            ),
            decoration: BoxDecoration(
              color: restaurant.isOpen ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              restaurant.isOpen ? 'Aberto' : 'Fechado',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10, // 🔥 antes 11
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
