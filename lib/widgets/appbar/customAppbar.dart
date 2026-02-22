import 'package:atlas/models/AppRoutes.dart';
import 'package:atlas/providers/ThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    final Color iconColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 2, // Légère ombre pour le relief
      toolbarHeight: 70,
      leading: IconButton(
        icon: Icon(Icons.menu_rounded, color: iconColor, size: 28),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      actions: [
        IconButton(
          tooltip: "Changer le mode",
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => RotationTransition(
              turns: anim,
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Icon(
              isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              key: ValueKey(isDark),
              color: isDark ? const Color.fromARGB(255, 242, 202, 80) : iconColor,
              size: 24,
            ),
          ),
          onPressed: () {
            themeProvider.toggleTheme(!isDark);
          },
        ),

        IconButton(
          icon: Icon(Icons.emoji_events_outlined, color: iconColor, size: 28),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.reward),
        ),
        IconButton(
          icon: Icon(Icons.shopping_cart_checkout, color: iconColor, size: 28),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.commande),
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}