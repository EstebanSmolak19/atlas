import 'package:flutter/material.dart';

class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DetailAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);
    final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: yellowColor,
      actions: [
        Padding(padding: EdgeInsetsGeometry.only(right: 10),
        child: IconButton(
          icon: const Icon(Icons.favorite_outline, color: Colors.black, size: 28),
          onPressed: () {},
          )
        )
      ],
    );
  }
}