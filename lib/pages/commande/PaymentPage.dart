import 'package:atlas/models/AppRoutes.dart';
import 'package:atlas/providers/CommandeProvider.dart';
import 'package:atlas/providers/HistoryProvider.dart';
import 'package:atlas/providers/UserProvider.dart';
import 'package:atlas/widgets/login/Toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentPage extends StatefulWidget {
  final double totalAmount;
  final int points;
  final int pointsToDeduct;

  const PaymentPage({
    super.key,
    required this.totalAmount,
    required this.points,
    this.pointsToDeduct = 0
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);
  final _formKey = GlobalKey<FormState>();

  bool _isProcessing = false;
  int _selectedPaymentMethod = 0;

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _holderNameController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _holderNameController.dispose();
    super.dispose();
  }

  void _showAddressPicker(List<String> savedAddresses, bool isDark, Color cardBg, Color textColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 15),
              Container(
                width: 50, height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10)
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Mes adresses",
                style: GoogleFonts.lilitaOne(fontSize: 24, color: textColor)
              ),
              const SizedBox(height: 20),

              Expanded(
                child: savedAddresses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.no_backpack_outlined, size: 50, color: isDark ? Colors.white10 : Colors.grey[300]),
                        const SizedBox(height: 10),
                        Text("Aucune adresse enregistrée", style: TextStyle(color: isDark ? Colors.white38 : Colors.grey)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: savedAddresses.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      final address = savedAddresses[index];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _addressController.text = address;
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.03), blurRadius: 10, offset: const Offset(0, 3))
                            ]
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark ? yellowColor : Colors.black,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.location_on, color: isDark ? Colors.black : yellowColor, size: 20),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Adresse ${index + 1}",
                                      style: TextStyle(color: isDark ? Colors.white38 : Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold)
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      address,
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textColor),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Colors.white24 : Colors.grey),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final savedAddresses = userProvider.user?.addresses ?? [];

    // --- LOGIQUE DE THÈME DYNAMIQUE ---
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final Color cardBg = Theme.of(context).cardColor;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.white38 : Colors.grey[700]!;
    // ---------------------------------

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Paiement",
          style: GoogleFonts.lilitaOne(color: textColor, fontSize: 24),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Où livrer ce festin ?",
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: textColor)
                        ),
                        if (savedAddresses.isNotEmpty)
                          GestureDetector(
                            onTap: () => _showAddressPicker(savedAddresses, isDark, cardBg, textColor),
                            child: Text(
                              "Mes adresses",
                              style: TextStyle(color: isDark ? yellowColor : Colors.grey[700], fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: _addressController,
                      style: TextStyle(color: textColor),
                      validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer une adresse' : null,
                      decoration: InputDecoration(
                        hintText: "12 Rue de la Pizza, 75000 Paris",
                        hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.grey),
                        prefixIcon: Icon(Icons.location_on_outlined, color: isDark ? yellowColor : Colors.black54),
                        suffixIcon: savedAddresses.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.keyboard_arrow_down, color: isDark ? Colors.white38 : Colors.black54),
                              onPressed: () => _showAddressPicker(savedAddresses, isDark, cardBg, textColor),
                            )
                          : null,
                        filled: true,
                        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: isDark ? yellowColor : Colors.black, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Text(
                      "Moyen de paiement",
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: textColor)
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        _buildPaymentMethodOption(0, "Carte", Icons.credit_card, isDark),
                        const SizedBox(width: 10),
                        _buildPaymentMethodOption(1, "Apple Pay", Icons.apple, isDark),
                        const SizedBox(width: 10),
                        _buildPaymentMethodOption(2, "Espèces", Icons.money, isDark),
                      ],
                    ),

                    const SizedBox(height: 30),

                    if (_selectedPaymentMethod == 0) ...[
                      AnimatedBuilder(
                        animation: Listenable.merge([_cardNumberController, _holderNameController, _expiryController]),
                        builder: (context, child) {
                          return Container(
                            width: double.infinity,
                            height: 200,
                            padding: const EdgeInsets.all(25),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                  ? [const Color(0xFF1E1E1E), Colors.black]
                                  : [Colors.black, Colors.grey.shade900],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: isDark ? Border.all(color: Colors.white10) : null,
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Icon(Icons.nfc, color: Colors.white54, size: 30),
                                    Text("ATLAS BANK", style: GoogleFonts.lilitaOne(color: Colors.white, fontSize: 18, letterSpacing: 2)),
                                  ],
                                ),
                                Text(
                                  _cardNumberController.text.isEmpty ? "**** **** **** ****" : _cardNumberController.text,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    letterSpacing: 2,
                                    fontFamily: 'Courier',
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Titulaire", style: TextStyle(color: Colors.white54, fontSize: 10)),
                                        Text(
                                          _holderNameController.text.isEmpty ? "VOYAGEUR ATLAS" : _holderNameController.text.toUpperCase(),
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        const Text("Exp", style: TextStyle(color: Colors.white54, fontSize: 10)),
                                        Text(
                                          _expiryController.text.isEmpty ? "MM/AA" : _expiryController.text,
                                          style: TextStyle(color: yellowColor, fontWeight: FontWeight.bold)
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 25),

                      _buildTextField(
                        controller: _cardNumberController,
                        hint: "Numéro de carte",
                        icon: Icons.credit_card,
                        isNumber: true,
                        maxLength: 19,
                        isDark: isDark,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _CardNumberFormatter(),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _expiryController,
                              hint: "MM/AA",
                              icon: Icons.calendar_today,
                              isNumber: true,
                              maxLength: 5,
                              isDark: isDark,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                _CardExpiryFormatter(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildTextField(
                              controller: _cvvController,
                              hint: "CVV",
                              icon: Icons.lock_outline,
                              isNumber: true,
                              maxLength: 3,
                              isDark: isDark,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        controller: _holderNameController,
                        hint: "Nom du titulaire",
                        icon: Icons.person_outline,
                        isNumber: false,
                        isDark: isDark,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.1), blurRadius: 20, offset: const Offset(0, -5))
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total à payer", style: TextStyle(fontSize: 16, color: isDark ? Colors.white38 : Colors.grey)),
                    Text(
                      "${widget.totalAmount.toStringAsFixed(2)}€",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textColor),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? yellowColor : Colors.black,
                      foregroundColor: isDark ? Colors.black : yellowColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    child: _isProcessing
                      ? CircularProgressIndicator(color: isDark ? Colors.black : yellowColor, strokeWidth: 3)
                      : const Text("Valider la commande", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool isNumber = false,
    int? maxLength,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      validator: (value) {
        if (_selectedPaymentMethod == 0 && (value == null || value.isEmpty)) {
          return 'Champ requis';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.grey),
        counterText: "",
        prefixIcon: Icon(icon, color: isDark ? yellowColor : Colors.grey),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: isDark ? yellowColor : Colors.black, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildPaymentMethodOption(int index, String label, IconData icon, bool isDark) {
    final isSelected = _selectedPaymentMethod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPaymentMethod = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: isSelected
              ? (isDark ? yellowColor : Colors.black)
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected
                ? (isDark ? yellowColor : Colors.black)
                : (isDark ? Colors.white10 : Colors.grey.shade300)
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                  ? (isDark ? Colors.black : yellowColor)
                  : (isDark ? Colors.white38 : Colors.grey)
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark ? Colors.white38 : Colors.grey),
                  fontWeight: FontWeight.bold,
                  fontSize: 12
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isProcessing = true);

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      try {
        final cartProvider = Provider.of<Commandeprovider>(context, listen: false);
        final historyProvider = Provider.of<HistoryProvider>(context, listen: false);
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        await historyProvider.createOrderFromCart(cartProvider, widget.totalAmount);

        final int pointsToAdd = widget.points;
        final int pointsToDeduct = widget.pointsToDeduct;

        if (pointsToDeduct > 0) {
          await userProvider.deductPoints(pointsToDeduct);
        }

        if (pointsToAdd > 0) {
          await userProvider.AddPoints(pointsToAdd);
        }

        cartProvider.clearCart();

        Toast.show(context, "Commande validée ! Un livreur est en route 🛵");
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);

      } catch (e) {
        print("Erreur paiement: $e");
        Toast.show(context, "Erreur lors de la commande");
        setState(() => _isProcessing = false);
      }
    }
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class _CardExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var newText = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    var buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != newText.length) {
        buffer.write('/');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}