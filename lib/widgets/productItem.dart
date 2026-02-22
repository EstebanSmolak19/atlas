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
    
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.white70 : Colors.grey[600]!;
    final Color imageBg = isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFFFF8E1);

    final double displayPrice = isMenu ? product.price + 3.99 : product.price;
    final String displayName = isMenu ? "Menu ${product.name}" : product.name;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: imageBg,
            borderRadius: BorderRadius.circular(16),
            border: isDark ? Border.all(color: Colors.white10) : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/${product.img_url}',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Image.asset('assets/pizza1.png'),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Infos Produit
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                displayName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  height: 1.2,
                  color: textColor,
                ),
              ),

              if (isMenu)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    "+ Accompagnement & Boisson",
                    style: TextStyle(
                      color: isDark ? yellowColor.withOpacity(0.8) : Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Icon(Icons.star_rounded, color: Colors.orange[400], size: 18),
                  const SizedBox(width: 4),
                  Text(
                    product.average.toStringAsFixed(1),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.access_time_filled_rounded,
                    color: isDark ? Colors.white30 : Colors.grey[400],
                    size: 16
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${product.time} min",
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${displayPrice.toStringAsFixed(2)}€",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: isDark ? yellowColor : Colors.black,
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark ? yellowColor : Colors.black,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isDark ? [
                        BoxShadow(
                          color: yellowColor.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ] : [],
                    ),
                    child: Icon(
                      Icons.add,
                      color: isDark ? Colors.black : Colors.white,
                      size: 20
                    ),
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