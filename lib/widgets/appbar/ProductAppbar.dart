import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductAppbar extends StatelessWidget implements PreferredSizeWidget{
  final bool showBackground;
  final bool showTitle;

  const ProductAppbar({
      super.key,
      this.showBackground = true,
      this.showTitle = true
    });

  @override
  Size get preferredSize => const Size.fromHeight(70);
  final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: showBackground ? yellowColor : Colors.transparent,
      title: showTitle ? Text(
        "Carte",
        style: GoogleFonts.lilitaOne(
          fontSize: 30,
          fontWeight: FontWeight.normal,
          letterSpacing: 2.5,
          color: const Color.fromARGB(
                  255, 51, 41, 38)
              .withOpacity(0.8),
          height: 1.0,
        ),
      ) : null ,
    );
  }
}