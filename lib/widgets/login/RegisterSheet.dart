import 'package:atlas/enum/InputType.dart';
import 'package:atlas/services/AuthService.dart';
import 'package:atlas/widgets/login/Toast.dart';
import 'package:atlas/widgets/login/inputField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterSheet extends StatefulWidget {
  const RegisterSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return const RegisterSheet();
      },
    );
  }


  @override
  State<RegisterSheet> createState() => _RegisterSheetState();
}

class _RegisterSheetState extends State<RegisterSheet> {
  final TextEditingController _regNameController = TextEditingController();
  final TextEditingController _regEmailController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();

  final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);

  @override
  void dispose() {
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Créer un compte",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            InputField(
              label: "Nom complet",
              controller: _regNameController,
              type: InputType.text,
            ),
            InputField(
              label: "Email",
              controller: _regEmailController,
              type: InputType.email,
            ),
            InputField(
              label: "Mot de passe",
              controller: _regPasswordController,
              type: InputType.password,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  AuthService().signUp(
                    email: _regEmailController.text.trim(), 
                    password: _regPasswordController.text.trim(), 
                    pseudo: _regNameController.text.trim()
                  );

                  Navigator.pop(context);
                  Toast.show(context, 'Compte créé avec succès !');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: yellowColor,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "S'inscrire",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}