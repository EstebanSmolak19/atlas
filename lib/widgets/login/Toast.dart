import 'package:flutter/material.dart';

class Toast extends StatelessWidget {
  final String message;
  final bool isDark;

  const Toast({
    super.key,
    required this.message,
    required this.isDark,
  });

  static void show(BuildContext context, String message) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    const Color yellowColor = Color.fromARGB(255, 242, 202, 80);
    final messenger = ScaffoldMessenger.of(context);

    messenger.removeCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Toast(message: message, isDark: isDark),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.black87,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: isDark ? const BorderSide(color: Colors.white10) : BorderSide.none,
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: yellowColor,
          onPressed: () {
            messenger.hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }
}