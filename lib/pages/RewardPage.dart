import 'package:atlas/models/RewardModel.dart';
import 'package:atlas/models/ProductModel.dart';
import 'package:atlas/providers/RewardProvider.dart';
import 'package:atlas/providers/UserProvider.dart';
import 'package:atlas/providers/CommandeProvider.dart';
import 'package:atlas/widgets/login/Toast.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RewardPage extends StatefulWidget {
  const RewardPage({super.key});

  @override
  State<RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);
  final Map<String, ProductModel> _productCache = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<RewardProvider>(context, listen: false).fetchRewards());
  }

  // Récupère un produit par son ID via Firestore ou Cache local
  Future<ProductModel?> _getProductById(String productId) async {
    if (_productCache.containsKey(productId)) {
      return _productCache[productId];
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        final product = ProductModel.fromMap(data);
        _productCache[productId] = product;
        return product;
      }
    } catch (e) {
      print("Erreur récupération produit $productId: $e");
    }
    return null;
  }

  // Logique de réclame de récompense
  Future<void> _handleRedeem(RewardModel reward, ProductModel? selectedProduct) async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    ProductModel? productToRedeem = selectedProduct;

    // Si la récompense contient plusieurs choix et qu'aucun n'est sélectionné
    if (reward.productIds.isNotEmpty && selectedProduct == null) {
      productToRedeem = await _showProductSelector(reward, isDark);
      if (productToRedeem == null) return;
    }

    if (productToRedeem == null && reward.productIds.isEmpty) {
      Toast.show(context, "Aucun produit disponible pour cette récompense");
      return;
    }

    final cartProvider = Provider.of<Commandeprovider>(context, listen: false);

    if (!cartProvider.canAffordReward(reward.cost)) {
      Toast.show(context, "Points insuffisants ! Vous avez ${cartProvider.availablePoints} points.");
      return;
    }

    if (cartProvider.hasAnyReward()) {
      Toast.show(context, "Une seule récompense autorisée par panier !");
      return;
    }

    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text("Utiliser ${reward.cost} pts ?",
            style: GoogleFonts.lilitaOne(color: isDark ? Colors.white : Colors.black)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (productToRedeem != null)
              Image.asset(
                'assets/${productToRedeem.img_url}',
                height: 100,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) =>
                    Icon(Icons.card_giftcard, size: 50, color: yellowColor),
              ),
            const SizedBox(height: 15),
            Text(
              productToRedeem?.name ?? reward.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text("Cet article sera ajouté gratuitement à votre panier.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: yellowColor, foregroundColor: Colors.black),
            child: const Text("Ajouter au panier"),
          )
        ],
      ),
    );

    if (confirm != true) return;

    try {
      cartProvider.addItem(
        productToRedeem!,
        1,
        isReward: true,
        rewardCost: reward.cost,
        rewardTier: reward.cost,
      );
      Toast.show(context, "✨ Récompense ajoutée !");
    } catch (e) {
      Toast.show(context, "Erreur lors de l'ajout.");
    }
  }

  // Sélecteur de produit si choix multiple
  Future<ProductModel?> _showProductSelector(RewardModel reward, bool isDark) async {
    final List<ProductModel> products = [];
    for (String productId in reward.productIds) {
      final product = await _getProductById(productId);
      if (product != null) products.add(product);
    }

    if (products.isEmpty) return null;

    return await showModalBottomSheet<ProductModel>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text("Choisissez votre cadeau", style: GoogleFonts.lilitaOne(fontSize: 22)),
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  final p = products[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.withOpacity(0.2))),
                    leading: Image.asset('assets/${p.img_url}', width: 50, errorBuilder: (c,e,s) => const Icon(Icons.fastfood)),
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.add_circle_outline, color: Colors.green),
                    onTap: () => Navigator.pop(ctx, p),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getTierName(int cost) {
    if (cost <= 50) return "L'Explorateur";
    if (cost <= 150) return "Le Gourmand";
    if (cost <= 300) return "L'Aventurier";
    if (cost <= 500) return "Le Conquérant";
    return "L'Empereur";
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final rewardProvider = context.watch<RewardProvider>();
    final cartProvider = context.watch<Commandeprovider>();

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black;

    final int currentPoints = userProvider.user?.points ?? 0;
    final int availablePoints = cartProvider.availablePoints;
    final List<RewardModel> allRewards = rewardProvider.rewards;

    // Groupement des récompenses par coût
    final Map<int, List<RewardModel>> groupedRewards = {};
    for (var r in allRewards) {
      if (!groupedRewards.containsKey(r.cost)) groupedRewards[r.cost] = [];
      groupedRewards[r.cost]!.add(r);
    }
    final List<int> sortedCosts = groupedRewards.keys.toList()..sort();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Fidélité", style: GoogleFonts.lilitaOne(fontSize: 24, color: textColor)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: textColor), onPressed: () => Navigator.pop(context)),
      ),
      body: rewardProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildHeaderProgress(currentPoints, availablePoints, sortedCosts, isDark),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    itemCount: sortedCosts.length,
                    itemBuilder: (context, index) {
                      final cost = sortedCosts[index];
                      final items = groupedRewards[cost]!;
                      return _buildTierSection(cost, items, availablePoints, isDark);
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderProgress(int currentPoints, int availablePoints, List<int> sortedCosts, bool isDark) {
    if (sortedCosts.isEmpty) return const SizedBox();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(
        children: [
          Text("$availablePoints Couronnes", style: GoogleFonts.lilitaOne(fontSize: 42, color: yellowColor)),
          Text("Points accumulés : $currentPoints", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          // Barre de progression simplifiée pour l'exemple
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: sortedCosts.map((cost) => _buildStepCircle(cost, availablePoints, isDark)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int cost, int currentPoints, bool isDark) {
    bool isReached = currentPoints >= cost;
    return Column(
      children: [
        Container(
          width: 35, height: 35,
          decoration: BoxDecoration(
            color: isReached ? yellowColor : Colors.grey.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: isReached ? Colors.black26 : Colors.transparent, width: 2),
          ),
          child: Icon(isReached ? Icons.check : Icons.lock, size: 16, color: isReached ? Colors.black : Colors.grey),
        ),
        const SizedBox(height: 5),
        Text("$cost", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isReached ? yellowColor : Colors.grey)),
      ],
    );
  }

  Widget _buildTierSection(int cost, List<RewardModel> items, int availablePoints, bool isDark) {
    bool isUnlocked = availablePoints >= cost;
    String tierName = _getTierName(cost);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: [
              Icon(isUnlocked ? Icons.stars : Icons.lock_outline, color: isUnlocked ? yellowColor : Colors.grey, size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("PALIER $cost PTS", style: GoogleFonts.lilitaOne(fontSize: 18, color: isUnlocked ? yellowColor : Colors.grey, letterSpacing: 1)),
                  Text(tierName, style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black54, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),

        // C'est ici que nous affichons les récompenses du palier
        ...items.map((reward) => _buildRewardGroup(reward, isUnlocked, isDark)),

        const Divider(indent: 20, endIndent: 20, height: 40, thickness: 0.5),
      ],
    );
  }

  Widget _buildRewardGroup(RewardModel reward, bool isUnlocked, bool isDark) {
    if (reward.productIds.isEmpty) {
      return _buildSingleRewardCard(reward, isUnlocked, isDark);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Text(reward.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        ),
        // CAROUSEL DE PRODUITS (SWIPABLE)
        SizedBox(
          height: 210, // Augmenté pour éviter les débordements
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(), // Ajout du feeling de glisse
            itemCount: reward.productIds.length,
            separatorBuilder: (_, __) => const SizedBox(width: 15),
            itemBuilder: (context, index) {
              return FutureBuilder<ProductModel?>(
                future: _getProductById(reward.productIds[index]),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container(width: 140, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(20)));
                  }
                  return _buildProductCard(reward, snapshot.data!, isUnlocked, isDark);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(RewardModel reward, ProductModel product, bool isUnlocked, bool isDark) {
    return Container(
      width: 150, // Largeur fixe pour permettre d'en voir plusieurs côte à côte
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: isUnlocked ? yellowColor.withOpacity(0.5) : Colors.transparent, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isUnlocked ? () => _handleRedeem(reward, product) : null,
          borderRadius: BorderRadius.circular(25),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Expanded(child: Image.asset('assets/${product.img_url}', fit: BoxFit.contain, errorBuilder: (c,e,s) => const Icon(Icons.fastfood, size: 50))),
                const SizedBox(height: 10),
                Text(product.name, textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, height: 1.1)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: isUnlocked ? yellowColor : Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                  child: Text(isUnlocked ? "CHOISIR" : "BLOQUÉ", style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.black)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSingleRewardCard(RewardModel reward, bool isUnlocked, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListTile(
        onTap: isUnlocked ? () => _handleRedeem(reward, null) : null,
        tileColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Icon(Icons.card_giftcard, color: isUnlocked ? yellowColor : Colors.grey),
        title: Text(reward.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(reward.description, style: const TextStyle(fontSize: 12)),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: isUnlocked ? yellowColor : Colors.grey),
      ),
    );
  }
}