import 'package:atlas/enum/InputType.dart';
import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final InputType type;

  const InputField({
    super.key,
    required this.label,
    required this.controller,
    this.type = InputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);

    String hintText;
    IconData icon;
    bool isObscure = false;
    TextInputType keyboardType = TextInputType.text;

    switch (type) {
      case InputType.email:
        hintText = "exemple@email.com";
        icon = Icons.email_outlined;
        keyboardType = TextInputType.emailAddress;
        break;
      case InputType.password:
        hintText = "********";
        icon = Icons.lock_outline;
        isObscure = true;
        break;
      case InputType.text:
        hintText = "Saisissez ici...";
          icon = Icons.edit_outlined;
          break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscure,
          keyboardType: keyboardType,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey[500]),
            prefixIcon: Icon(icon, color: isDark ? Colors.white60 : Colors.grey[600]),
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: isDark ? Colors.white10 : Colors.transparent,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: isDark ? yellowColor : Colors.black,
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}