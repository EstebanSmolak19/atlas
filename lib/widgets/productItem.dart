import 'package:atlas/models/ProductModel.dart';
import 'package:flutter/material.dart';

class ProductItem extends StatelessWidget {
  final ProductModel product;
  final bool isMenu;

  const ProductItem({
    super.key,
    required this.product,
    this.isMenu = false,
  });

  @override
  Widget build(BuildContext context) {
    final double displayPrice = isMenu ? product.price + 3.99 : product.price;
    final String displayName = isMenu ? "Menu ${product.name}" : product.name;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/${product.img_url}',
              errorBuilder: (context, error, stackTrace) => Image.asset('assets/pizza1.png'),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                displayName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  height: 1.2,
                ),
              ),
              // --- AJOUT : Sous-titre pour le Menu ---
              if (isMenu)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    "+ Accompagnement & Boisson",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              // --------------------------------------
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.star_rounded, color: Colors.orange[400], size: 18),
                  const SizedBox(width: 4),
                  Text(
                    product.average.toStringAsFixed(1),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.access_time_filled_rounded,
                      color: Colors.grey[400], size: 16),
                  const SizedBox(width: 4),
                  Text(
                    "${product.time} min",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${displayPrice.toStringAsFixed(2)}€",
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}