import 'package:atlas/providers/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);
  int _selectedPlanIndex = 1;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _plans = [
    {
      "name": "NOMAD",
      "price": "4.99€",
      "period": "/ mois",
      "savings": null,
      "id": "basic",
      "benefits": [
        "Livraison offerte dès 30€ 🛵",
        "5% de réduction sur les menus 🏷️",
        "Accès aux ventes privées"
      ]
    },
    {
      "name": "EXPLORER",
      "price": "9.99€",
      "period": "/ mois",
      "savings": "Populaire",
      "id": "standard",
      "benefits": [
        "Livraison offerte illimitée 🚀",
        "10% de réduction sur tout 💎",
        "Service client prioritaire 24/7",
        "Badge Explorer exclusif"
      ]
    },
    {
      "name": "ELITE",
      "price": "19.99€",
      "period": "/ mois",
      "savings": "Best",
      "id": "premium",
      "benefits": [
        "Livraison offerte illimitée 🚀",
        "20% de réduction sur tout 🔥",
        "Points fidélité doublés (x2) 🌟",
        "Un dessert offert / commande 🍰"
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserProvider>(context, listen: false).user;

      if (user != null && user.premium && user.planId != null) {
        final index = _plans.indexWhere((p) => p['id'] == user.planId);
        if (index != -1) {
          setState(() {
            _selectedPlanIndex = index;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user!;
    final bool isPremium = user.premium;
    final String? currentPlanId = user.planId;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final Color cardBg = Theme.of(context).cardColor;
    final Color textColor = isDark ? Colors.white : Colors.black;

    final List<String> currentBenefits = _plans[_selectedPlanIndex]['benefits'];

    String buttonText = "Confirmer l'abonnement";
    Color buttonColor = isDark ? yellowColor : Colors.black;
    Color buttonTextColor = isDark ? Colors.black : yellowColor;

    if (isPremium) {
      if (_plans[_selectedPlanIndex]['id'] == currentPlanId) {
        buttonText = "Résilier mon abonnement";
        buttonColor = isDark ? Colors.white10 : Colors.white;
        buttonTextColor = Colors.red;
      } else {
        buttonText = "Changer pour l'offre ${_plans[_selectedPlanIndex]['name']}";
        buttonColor = isDark ? yellowColor : Colors.black;
        buttonTextColor = isDark ? Colors.black : Colors.white;
      }
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            height: 300,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: -50, right: -50,
                    child: Icon(Icons.star, color: Colors.white.withOpacity(0.05), size: 300),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.diamond_outlined, color: yellowColor, size: 50),
                      const SizedBox(height: 10),
                      Text(
                        isPremium ? "MON ABONNEMENT" : "ATLAS PREMIUM",
                        style: GoogleFonts.lilitaOne(color: Colors.white, fontSize: 32, letterSpacing: 2),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        isPremium
                          ? "Membre ${_plans.firstWhere((p) => p['id'] == currentPlanId, orElse: () => _plans[1])['name']} Actif"
                          : "Voyagez en première classe",
                        style: TextStyle(color: yellowColor, fontSize: 14, letterSpacing: 1, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 50, left: 20,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),

          Column(
            children: [
              const SizedBox(height: 280),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      Center(
                        child: Text(
                          isPremium ? "Gérer votre offre" : "Choisissez votre formule",
                          style: GoogleFonts.lilitaOne(fontSize: 22, color: textColor)
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: List.generate(_plans.length, (index) {
                          final plan = _plans[index];
                          final isSelected = _selectedPlanIndex == index;
                          final isCurrentPlan = isPremium && plan['id'] == currentPlanId;

                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedPlanIndex = index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDark ? yellowColor : Colors.black)
                                      : cardBg,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: isSelected
                                      ? (isDark ? yellowColor : Colors.black)
                                      : (isCurrentPlan ? yellowColor : (isDark ? Colors.white10 : Colors.grey.shade300)),
                                    width: (isSelected || isCurrentPlan) ? 2 : 1
                                  ),
                                  boxShadow: isSelected ? [
                                    BoxShadow(color: Colors.black.withOpacity(isDark ? 0.4 : 0.2), blurRadius: 8, offset: const Offset(0, 4))
                                  ] : [],
                                ),
                                child: Column(
                                  children: [
                                    if (isCurrentPlan)
                                      Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.white24 : yellowColor,
                                          borderRadius: BorderRadius.circular(8)
                                        ),
                                        child: Text(
                                          "ACTUEL",
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? Colors.white : Colors.black
                                          )
                                        ),
                                      )
                                    else if (plan['savings'] != null)
                                      Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.white24 : Colors.green[100],
                                          borderRadius: BorderRadius.circular(8)
                                        ),
                                        child: Text(
                                          plan['savings'],
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? Colors.white : Colors.green[800]
                                          )
                                        ),
                                      )
                                    else
                                      const SizedBox(height: 18),

                                    Text(
                                      plan['name'],
                                      style: TextStyle(
                                        color: isSelected
                                            ? (isDark ? Colors.black54 : Colors.grey)
                                            : (isDark ? Colors.white60 : Colors.grey[600]),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1
                                      )
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      plan['price'],
                                      style: TextStyle(
                                        color: isSelected
                                            ? (isDark ? Colors.black : Colors.white)
                                            : textColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900
                                      )
                                    ),
                                    Text(
                                      plan['period'],
                                      style: TextStyle(
                                        color: isSelected
                                            ? (isDark ? Colors.black45 : Colors.grey)
                                            : (isDark ? Colors.white38 : Colors.grey[600]),
                                        fontSize: 10
                                      )
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 30),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          "Avantages inclus :",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)
                        ),
                      ),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Column(
                          key: ValueKey<int>(_selectedPlanIndex),
                          children: currentBenefits.map((benefit) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(color: yellowColor.withOpacity(0.2), shape: BoxShape.circle),
                                  child: Icon(Icons.check, size: 12, color: isDark ? yellowColor : Colors.black),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    benefit,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: isDark ? Colors.white70 : Colors.black87
                                    )
                                  )
                                ),
                              ],
                            ),
                          )).toList(),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: cardBg,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -5)
                    )
                  ]
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // Logique d'abonnement à implémenter
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: buttonTextColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: (isPremium && _plans[_selectedPlanIndex]['id'] == currentPlanId)
                            ? const BorderSide(color: Colors.red, width: 2)
                            : BorderSide.none
                      ),
                      elevation: (isPremium && _plans[_selectedPlanIndex]['id'] == currentPlanId) ? 0 : 5,
                    ),
                    child: _isLoading
                      ? SizedBox(
                          height: 25,
                          width: 25,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: buttonTextColor
                          )
                        )
                      : Text(
                          buttonText,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}