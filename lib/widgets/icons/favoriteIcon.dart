import 'package:atlas/models/ProductModel.dart';
import 'package:atlas/providers/FavoriteProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoriteIconButton extends StatelessWidget {
  final ProductModel product;
  final Color color;

  const FavoriteIconButton({
    super.key,
    required this.product,
    required this.color
  });

  @override
  Widget build(BuildContext context) {

    final favoriteProvider = context.watch<FavoriteProvider>();
    final isFav = favoriteProvider.isFavorite(product.id);

    return IconButton(
      onPressed: () => favoriteProvider.toggleFavorite(product),

    icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
        child: Icon(
          isFav ? Icons.favorite : Icons.favorite_border,
          key: ValueKey(isFav),
          color: isFav ? Colors.red : color,
          size: 28,
        ),
      ),
    );
  }
}