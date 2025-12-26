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
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscure, 
          keyboardType: keyboardType, 
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}