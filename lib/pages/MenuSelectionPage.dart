import 'package:atlas/models/ProductModel.dart';
import 'package:atlas/providers/CommandeProvider.dart';
import 'package:atlas/widgets/login/Toast.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MenuSelectionPage extends StatefulWidget {
  final ProductModel mainProduct;

  const MenuSelectionPage({super.key, required this.mainProduct});

  @override
  State<MenuSelectionPage> createState() => _MenuSelectionPageState();
}

class _MenuSelectionPageState extends State<MenuSelectionPage> {
  int _currentStep = 0;
  final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);

  //Temporaire.
  final List<Map<String, String>> _sides = [
    {'name': 'Frites Classiques', 'image': 'assets/fries.png'},
    {'name': 'Potatoes', 'image': 'assets/potatoes.png'},
    {'name': 'Salade César', 'image': 'assets/salad.png'},
  ];

  final List<Map<String, String>> _drinks = [
    {'name': 'Coca-Cola', 'image': 'assets/coca.png'},
    {'name': 'Eau Minérale', 'image': 'assets/water.png'},
    {'name': 'Fanta Orange', 'image': 'assets/fanta.png'},
    {'name': 'Ice Tea', 'image': 'assets/icetea.png'},
  ];

  int? _selectedSideIndex;
  int? _selectedDrinkIndex;

  void _nextStep() {
    if (_currentStep == 0 && _selectedSideIndex == null) {
      Toast.show(context, "Veuillez choisir un accompagnement");
      return;
    }
    if (_currentStep == 1 && _selectedDrinkIndex == null) {
      Toast.show(context, "Veuillez choisir une boisson");
      return;
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _addToCart();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  void _addToCart() {
    final cartProvider = Provider.of<Commandeprovider>(context, listen: false);
    
    ProductModel menuProduct = ProductModel(
      id: "${widget.mainProduct.id}_menu",
      name: "Menu ${widget.mainProduct.name}",
      description: "${_sides[_selectedSideIndex!]['name']} + ${_drinks[_selectedDrinkIndex!]['name']}",
      price: widget.mainProduct.price + 4.0,
      average: widget.mainProduct.average,
      calorie: widget.mainProduct.calorie + 400,
      time: widget.mainProduct.time,
      type: widget.mainProduct.type,
      rating_count: widget.mainProduct.rating_count,
      nationality: widget.mainProduct.nationality,
      img_url: widget.mainProduct.img_url,
    );

    cartProvider.addItem(menuProduct, 1);
    
    Toast.show(context, "Menu ajouté au panier !");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Composer mon Menu",
          style: GoogleFonts.lilitaOne(color: Colors.black, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          
          Expanded(
            child: _currentStep == 0 
                ? _buildSelectionGrid("Choisissez votre accompagnement", _sides, _selectedSideIndex, (i) => setState(() => _selectedSideIndex = i))
                : _currentStep == 1
                    ? _buildSelectionGrid("Choisissez votre boisson", _drinks, _selectedDrinkIndex, (i) => setState(() => _selectedDrinkIndex = i))
                    : _buildRecap(),
          ),

          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _buildStepIndicator(0, "Frites"),
          _buildStepLine(0),
          _buildStepIndicator(1, "Boisson"),
          _buildStepLine(1),
          _buildStepIndicator(2, "Terminé"),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    bool isActive = _currentStep >= step;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 30, height: 30,
          decoration: BoxDecoration(
            color: isActive ? Colors.black : Colors.grey[200],
            shape: BoxShape.circle,
            border: isActive ? null : Border.all(color: Colors.grey[300]!),
          ),
          child: Center(
            child: isActive 
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : Text("${step + 1}", style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? Colors.black : Colors.grey)),
      ],
    );
  }

  Widget _buildStepLine(int step) {
    return Expanded(
      child: Container(
        height: 2,
        color: _currentStep > step ? Colors.black : Colors.grey[200],
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      ),
    );
  }

  Widget _buildSelectionGrid(String title, List<Map<String, String>> items, int? selectedIndex, Function(int) onSelect) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = selectedIndex == index;
              return GestureDetector(
                onTap: () => onSelect(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? yellowColor.withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? yellowColor : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected 
                        ? [BoxShadow(color: yellowColor.withOpacity(0.2), blurRadius: 10)] 
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Placeholder pour l'image si elle n'existe pas
                      Container(
                        height: 80, width: 80,
                        decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                        child: const Icon(Icons.fastfood, size: 40, color: Colors.grey), 
                        // Image.asset(item['image']!) // Décommenter quand tu auras les images
                      ),
                      const SizedBox(height: 15),
                      Text(
                        item['name']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.black : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecap() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Text("Récapitulatif de votre Menu", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildRecapItem("Plat", widget.mainProduct.name),
                const Divider(),
                _buildRecapItem("Accompagnement", _sides[_selectedSideIndex!]['name']!),
                const Divider(),
                _buildRecapItem("Boisson", _drinks[_selectedDrinkIndex!]['name']!),
              ],
            ),
          ),
          const Spacer(),
          Text(
            "Total: ${(widget.mainProduct.price + 4.0).toStringAsFixed(2)}€",
            style: GoogleFonts.lilitaOne(fontSize: 32, color: Colors.black),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRecapItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              flex: 1,
              child: TextButton(
                onPressed: _previousStep,
                child: const Text("Retour", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text(
                _currentStep == 2 ? "Ajouter au panier" : "Suivant",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}