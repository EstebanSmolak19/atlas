import 'package:atlas/models/ProductModel.dart';
import 'package:atlas/widgets/icons/favoriteIcon.dart';
import 'package:flutter/material.dart';

class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DetailAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);
    final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as ProductModel;

    return AppBar(
      backgroundColor: yellowColor,
      actions: [
        Padding(padding: EdgeInsetsGeometry.only(right: 10),
        child: FavoriteIconButton(
            product: product,
            color: Colors.black,
          )
        )
      ],
    );
  }
}