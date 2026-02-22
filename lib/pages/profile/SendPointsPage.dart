import 'package:atlas/providers/SocialProvider.dart';
import 'package:atlas/providers/UserProvider.dart';
import 'package:atlas/widgets/login/Toast.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SendPointsPage extends StatefulWidget {
  const SendPointsPage({super.key});

  @override
  State<SendPointsPage> createState() => _SendPointsPageState();
}

class _SendPointsPageState extends State<SendPointsPage> {
  final TextEditingController _amountController = TextEditingController();
  final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);

  @override
  Widget build(BuildContext context) {
    final dynamic args = ModalRoute.of(context)?.settings.arguments;

    if (args == null || args is! Map<String, dynamic>) {
      return Scaffold(
        appBar: AppBar(title: const Text("Don de points")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 20),
              const Text("Sélectionne d'abord un ami dans ta liste."),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("RETOUR AUX AMIS"),
              )
            ],
          ),
        ),
      );
    }

    final Map<String, dynamic> friend = args;
    final userProvider = context.watch<UserProvider>();
    final socialProvider = context.watch<SocialProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Faire un don", style: GoogleFonts.lilitaOne(fontSize: 22, color: textColor)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            // Destinataire
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.black,
                borderRadius: BorderRadius.circular(20)
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: yellowColor,
                    child: Text(
                      friend['pseudo'] != null ? friend['pseudo'][0].toUpperCase() : "?",
                      style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)
                    )
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Envoyer à", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text(
                          friend['pseudo'] ?? "Inconnu",
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            Text("Combien de points ?", style: GoogleFonts.lilitaOne(fontSize: 20, color: textColor)),
            const SizedBox(height: 10),
            Text("Tes points disponibles : ${userProvider.user?.points ?? 0} pts", style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 30),

            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: GoogleFonts.lilitaOne(fontSize: 48, color: yellowColor),
              decoration: const InputDecoration(
                hintText: "0",
                border: InputBorder.none,
              ),
            ),

            const SizedBox(height: 50),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: socialProvider.isLoading ? null : () async {
                  final amount = int.tryParse(_amountController.text) ?? 0;
                  if (amount <= 0) {
                    Toast.show(context, "Entre un montant valide !");
                    return;
                  }
                  if (amount > (userProvider.user?.points ?? 0)) {
                    Toast.show(context, "Solde insuffisant !");
                    return;
                  }

                  try {
                    await socialProvider.sendPoints(friend['uid'], amount, friend['pseudo']);
                    await userProvider.loadUser(); // Rafraîchir le solde local
                    if (mounted) {
                      Navigator.pop(context);
                      Toast.show(context, "✨ $amount points envoyés à ${friend['pseudo']} !");
                    }
                  } catch (e) {
                    if (mounted) Toast.show(context, "Erreur lors du transfert");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? yellowColor : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: socialProvider.isLoading
                  ? const CircularProgressIndicator()
                  : const Text("CONFIRMER LE DON", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}