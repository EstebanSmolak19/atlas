import 'package:atlas/providers/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);

  void _showAddAddressDialog(BuildContext context, bool isDark, Color cardBg, Color textColor) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Nouvelle adresse",
            style: GoogleFonts.lilitaOne(fontSize: 24, color: textColor)
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Où souhaitez-vous être livré ?",
                style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: controller,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: "Ex: 10 Rue de Atlas...",
                  hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.grey[400]),
                  prefixIcon: Icon(Icons.location_on_outlined, color: isDark ? yellowColor : Colors.grey[400]),
                  filled: true,
                  fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF9F9F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: isDark ? yellowColor : Colors.black, width: 1.5)
                  ),
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Annuler", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        Provider.of<UserProvider>(context, listen: false).addAddress(controller.text);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? yellowColor : Colors.black,
                      foregroundColor: isDark ? Colors.black : yellowColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Ajouter", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final addresses = userProvider.user?.addresses ?? [];

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final Color cardBg = Theme.of(context).cardColor;
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? cardBg : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
                ]
              ),
              child: Icon(Icons.arrow_back, color: textColor, size: 20),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          "Mes Adresses",
          style: GoogleFonts.lilitaOne(color: textColor, fontSize: 24),
        ),
      ),
      body: addresses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: yellowColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.location_off_outlined, size: 50, color: yellowColor),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Aucune adresse",
                    style: GoogleFonts.lilitaOne(fontSize: 22, color: textColor),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Ajoutez vos lieux favoris pour\nune livraison express.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              itemCount: addresses.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                final address = addresses[index];
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? Colors.white10 : Colors.transparent),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? yellowColor : Colors.black,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(Icons.home_outlined, color: isDark ? Colors.black : yellowColor, size: 22),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Adresse ${index + 1}",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white38 : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              address,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.red.withOpacity(0.1) : Colors.red[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.delete_outline, color: isDark ? Colors.red[300] : Colors.red[300], size: 18),
                        ),
                        onPressed: () => userProvider.removeAddress(address),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAddressDialog(context, isDark, cardBg, textColor),
        backgroundColor: isDark ? yellowColor : Colors.black,
        elevation: 5,
        icon: Icon(Icons.add, color: isDark ? Colors.black : yellowColor),
        label: Text(
          "Ajouter une adresse",
          style: TextStyle(color: isDark ? Colors.black : yellowColor, fontWeight: FontWeight.w900),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}