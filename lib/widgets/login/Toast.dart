import 'package:flutter/material.dart';

class Toast extends StatelessWidget {
  final String message;

  const Toast({
    super.key, 
    required this.message
  });

  static void show(BuildContext context, String message) {
    const Color yellowColor = Color.fromARGB(255, 242, 202, 80);
    final messenger = ScaffoldMessenger.of(context);

    messenger.showSnackBar(
      SnackBar(
        content: Toast(message: message),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
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
      style: const TextStyle(color: Colors.white),
    );
  }
}