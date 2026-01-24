import 'package:atlas/models/AppRoutes.dart';
import 'package:atlas/providers/CommandeProvider.dart';
import 'package:atlas/providers/UserProvider.dart';
import 'package:atlas/widgets/login/Toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PaymentPage extends StatefulWidget {
  final double totalAmount;

  const PaymentPage({super.key, required this.totalAmount});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);
  final _formKey = GlobalKey<FormState>();
  
  bool _isProcessing = false;
  int _selectedPaymentMethod = 0; 
  int _lastCardLength = 0;
  int _lastExpiryLength = 0;

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

  void _showAddressPicker(List<String> savedAddresses) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 15),
              Container(
                width: 50, height: 5,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 20),
              Text("Mes adresses", style: GoogleFonts.lilitaOne(fontSize: 24, color: Colors.black)),
              const SizedBox(height: 20),
              
              Expanded(
                child: savedAddresses.isEmpty 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.no_backpack_outlined, size: 50, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        const Text("Aucune adresse enregistrée", style: TextStyle(color: Colors.grey)),
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3))
                            ]
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.location_on, color: yellowColor, size: 20),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Adresse ${index + 1}", style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 2),
                                    Text(
                                      address,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Paiement",
          style: GoogleFonts.lilitaOne(color: Colors.black, fontSize: 24),
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
                        const Text("Où livrer ce festin ?", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                        if (savedAddresses.isNotEmpty)
                          GestureDetector(
                            onTap: () => _showAddressPicker(savedAddresses),
                            child: Text(
                              "Mes adresses",
                              style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: _addressController,
                      validator: (value) => value == null || value.isEmpty ? 'Veuillez entrer une adresse' : null,
                      decoration: InputDecoration(
                        hintText: "12 Rue de la Pizza, 75000 Paris",
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        suffixIcon: savedAddresses.isNotEmpty 
                          ? IconButton(
                              icon: const Icon(Icons.keyboard_arrow_down),
                              onPressed: () => _showAddressPicker(savedAddresses),
                            )
                          : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text("Moyen de paiement", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        _buildPaymentMethodOption(0, "Carte", Icons.credit_card),
                        const SizedBox(width: 10),
                        _buildPaymentMethodOption(1, "Apple Pay", Icons.apple),
                        const SizedBox(width: 10),
                        _buildPaymentMethodOption(2, "Espèces", Icons.money),
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
                                colors: [Colors.black, Colors.grey.shade900],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
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
                                  style: TextStyle(
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
                        onChanged: (val) {
                          if (val.length > _lastCardLength) {
                            if (val.length < 19 && val.replaceAll(' ', '').length % 4 == 0 && !val.endsWith(' ')) {
                               _cardNumberController.text = "$val ";
                               _cardNumberController.selection = TextSelection.fromPosition(TextPosition(offset: _cardNumberController.text.length));
                            }
                          }
                          _lastCardLength = _cardNumberController.text.length;
                        }
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
                              onChanged: (val) {
                                if (val.length > _lastExpiryLength) {
                                  if (val.length == 2 && !val.contains('/')) {
                                    _expiryController.text = "$val/";
                                    _expiryController.selection = TextSelection.fromPosition(TextPosition(offset: _expiryController.text.length));
                                  }
                                }
                                _lastExpiryLength = _expiryController.text.length;
                              }
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
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total à payer", style: TextStyle(fontSize: 16, color: Colors.grey)),
                    Text(
                      "${widget.totalAmount.toStringAsFixed(2)}€",
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
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
                      backgroundColor: Colors.black,
                      foregroundColor: yellowColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    child: _isProcessing
                      ? SizedBox(height: 25, width: 25, child: CircularProgressIndicator(color: yellowColor, strokeWidth: 3))
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
    bool isNumber = false,
    int? maxLength,
    Function(String)? onChanged,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLength: maxLength,
      onChanged: onChanged,
      validator: (value) {
        if (_selectedPaymentMethod == 0 && (value == null || value.isEmpty)) {
          return 'Champ requis';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        counterText: "",
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildPaymentMethodOption(int index, String label, IconData icon) {
    final isSelected = _selectedPaymentMethod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPaymentMethod = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? yellowColor : Colors.grey),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
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
      Provider.of<Commandeprovider>(context, listen: false).clearCart();
      Toast.show(context, "Commande validée ! Un livreur est en route 🛵");
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
    }
  }
}