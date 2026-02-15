import 'package:atlas/models/RewardModel.dart';
import 'package:atlas/models/ProductModel.dart';
import 'package:atlas/providers/RewardProvider.dart';
import 'package:atlas/providers/UserProvider.dart';
import 'package:atlas/providers/ProductProvider.dart';
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

  // Récupère un produit par son ID
  Future<ProductModel?> _getProductById(String productId) async {
    // Check cache d'abord
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

  Future<void> _handleRedeem(RewardModel reward, ProductModel? selectedProduct) async {
    ProductModel? productToRedeem = selectedProduct;

    if (reward.productIds.isNotEmpty && selectedProduct == null) {
      // L'utilisateur doit choisir un produit
      productToRedeem = await _showProductSelector(reward);
      if (productToRedeem == null) return; // Annulé
    }

    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Échanger ${reward.cost} pts ?",
            style: GoogleFonts.lilitaOne()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (productToRedeem != null && productToRedeem.img_url.isNotEmpty)
              Image.asset(
                productToRedeem.img_url,
                height: 80,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.card_giftcard, size: 50),
              )
            else
              const Icon(Icons.card_giftcard, size: 50),
            const SizedBox(height: 10),
            Text("Vous allez obtenir :",
                style: TextStyle(color: Colors.grey[600])),
            Text(
              productToRedeem?.name ?? reward.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
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
                backgroundColor: Colors.black, foregroundColor: yellowColor),
            child: const Text("Valider"),
          )
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await Provider.of<RewardProvider>(context, listen: false)
          .redeemReward(reward);
      if (mounted) {
        await Provider.of<UserProvider>(context, listen: false).loadUser();
        Toast.show(context, "Félicitations ! Récompense obtenue 🎁");
      }
    } catch (e) {
      if (mounted) {
        Toast.show(context, e.toString().replaceAll("Exception: ", ""));
      }
    }
  }

  Future<ProductModel?> _showProductSelector(RewardModel reward) async {
    // Charger tous les produits
    final List<ProductModel> products = [];
    for (String productId in reward.productIds) {
      final product = await _getProductById(productId);
      if (product != null) products.add(product);
    }

    if (products.isEmpty) return null;

    return await showModalBottomSheet<ProductModel>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              reward.description,
              style: GoogleFonts.lilitaOne(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return InkWell(
                    onTap: () => Navigator.pop(ctx, product),
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            product.img_url,
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                            errorBuilder: (c, e, s) =>
                                const Icon(Icons.fastfood, size: 50),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios,
                              size: 16, color: Colors.grey[400]),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
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
    final int currentPoints = userProvider.user?.points ?? 0;
    final List<RewardModel> allRewards = rewardProvider.rewards;

    // Regroupement par coût
    final Map<int, List<RewardModel>> groupedRewards = {};
    for (var r in allRewards) {
      if (!groupedRewards.containsKey(r.cost)) groupedRewards[r.cost] = [];
      groupedRewards[r.cost]!.add(r);
    }
    final List<int> sortedCosts = groupedRewards.keys.toList()..sort();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Fidélité",
          style: GoogleFonts.lilitaOne(color: Colors.black, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: rewardProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.black))
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderProgress(currentPoints, sortedCosts),
                  const SizedBox(height: 10),
                  if (sortedCosts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                          child: Text(
                              "Aucune récompense disponible pour le moment.")),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      itemCount: sortedCosts.length,
                      itemBuilder: (context, index) {
                        final cost = sortedCosts[index];
                        final items = groupedRewards[cost]!;
                        return _buildTierSection(cost, items, currentPoints);
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderProgress(int currentPoints, List<int> sortedCosts) {
    if (sortedCosts.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Column(
        children: [
          Text(
            "$currentPoints Couronnes",
            style: GoogleFonts.lilitaOne(fontSize: 36, color: Colors.brown[800]),
          ),
          const SizedBox(height: 25),
          LayoutBuilder(
            builder: (context, constraints) {
              final int segmentsCount = sortedCosts.length;
              double fillPercent = 0.0;

              if (currentPoints >= sortedCosts.last) {
                // Tous les paliers atteints
                fillPercent = 1.0;
              } else if (currentPoints < sortedCosts.first) {
                // Avant le premier palier
                // On calcule la progression de 0 jusqu'au premier cercle
                // Le premier segment va de 0 au centre du premier cercle
                fillPercent = (currentPoints / sortedCosts.first) / segmentsCount;
              } else {
                // Entre deux paliers
                for (int i = 0; i < sortedCosts.length - 1; i++) {
                  int start = sortedCosts[i];
                  int end = sortedCosts[i + 1];
                  if (currentPoints >= start && currentPoints < end) {
                    // Progression dans le segment actuel
                    // On part du centre du cercle i vers le centre du cercle i+1
                    double baseProgress = (i + 0.5) / segmentsCount; // Position du cercle i
                    double segmentWidth = 1.0 / segmentsCount; // Largeur d'un segment
                    double progressInSegment = (currentPoints - start) / (end - start);
                    fillPercent = baseProgress + (progressInSegment * segmentWidth);
                    break;
                  }
                }
                // Si on est au dernier palier atteint mais pas encore au suivant
                if (fillPercent == 0.0 && currentPoints >= sortedCosts[sortedCosts.length - 1]) {
                  fillPercent = (sortedCosts.length - 0.5) / segmentsCount;
                }
              }

              return SizedBox(
                height: 50,
                child: Stack(
                  children: [
                    // Cercles paliers (en arrière-plan pour calculer les positions)
                    Positioned.fill(
                      child: Row(
                        children: List.generate(sortedCosts.length, (index) {
                          return Expanded(
                            child: Container(), // Placeholder pour espacer
                          );
                        }),
                      ),
                    ),
                    // Fond gris et barre jaune centrés verticalement
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 13, // Centré avec les cercles (30px de hauteur / 2 - 3px de hauteur barre / 2)
                      child: Stack(
                        children: [
                          // Fond gris
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          // Barre jaune
                          FractionallySizedBox(
                            widthFactor: fillPercent > 1.0
                                ? 1.0
                                : (fillPercent < 0 ? 0 : fillPercent),
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: yellowColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Cercles paliers au premier plan
                    Positioned.fill(
                      child: Row(
                        children: List.generate(sortedCosts.length, (index) {
                          return Expanded(
                            child: _buildStepCircle(sortedCosts[index], currentPoints),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildStepCircle(int cost, int currentPoints) {
    bool isReached = currentPoints >= cost;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
              color: isReached ? yellowColor : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                  color: isReached ? yellowColor : Colors.grey[300]!, width: 3),
              boxShadow: isReached
                  ? [
                      BoxShadow(
                          color: yellowColor.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ]
                  : []),
          child: isReached
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          "$cost",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isReached ? Colors.black : Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildTierSection(int cost, List<RewardModel> items, int currentPoints) {
    bool isUnlocked = currentPoints >= cost;
    String tierName = _getTierName(cost);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TITRE PALIER
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Icon(
                isUnlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                color: isUnlocked ? Colors.black : Colors.grey,
                size: 22,
              ),
              const SizedBox(width: 10),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                      fontFamily: 'RedHat', color: Colors.black),
                  children: [
                    TextSpan(
                      text: "Palier $cost pts : ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isUnlocked ? Colors.black : Colors.grey),
                    ),
                    TextSpan(
                      text: tierName,
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: isUnlocked ? yellowColor : Colors.grey[400]),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (isUnlocked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: yellowColor, borderRadius: BorderRadius.circular(4)),
                  child: const Text("DISPONIBLE",
                      style:
                          TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                )
            ],
          ),
        ),

        // POUR CHAQUE REWARD DU PALIER
        ...items.map((reward) => _buildRewardWithOptions(reward, isUnlocked)),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRewardWithOptions(RewardModel reward, bool isUnlocked) {
    // Si pas de produits, afficher juste le reward simple
    if (reward.productIds.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: _buildSingleRewardCard(reward, isUnlocked, null),
      );
    }

    // Si produits disponibles, afficher le titre + les produits en horizontal
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description du reward
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Text(
            reward.description,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isUnlocked ? Colors.black87 : Colors.grey[600],
            ),
          ),
        ),

        // Liste horizontale des produits
        SizedBox(
          height: 190,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: reward.productIds.length,
            separatorBuilder: (ctx, i) => const SizedBox(width: 15),
            itemBuilder: (context, index) {
              final productId = reward.productIds[index];
              return FutureBuilder<ProductModel?>(
                future: _getProductById(productId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      width: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }

                  final product = snapshot.data;
                  if (product == null) {
                    return const SizedBox.shrink();
                  }

                  return _buildProductCard(reward, product, isUnlocked);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(
      RewardModel reward, ProductModel product, bool isUnlocked) {
    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.6,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isUnlocked
              ? Border.all(color: Colors.black, width: 2)
              : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isUnlocked ? () => _handleRedeem(reward, product) : null,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Image.asset(
                      product.img_url,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) =>
                          const Icon(Icons.fastfood, size: 40, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isUnlocked ? Colors.black : Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isUnlocked ? yellowColor : Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_forward,
                        color: isUnlocked ? Colors.black : Colors.grey, size: 16),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSingleRewardCard(
      RewardModel reward, bool isUnlocked, ProductModel? product) {
    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.6,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isUnlocked
              ? Border.all(color: Colors.black, width: 2)
              : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.card_giftcard, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isUnlocked ? Colors.black : Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reward.description,
                    style: TextStyle(
                        fontSize: 13,
                        color: isUnlocked ? Colors.grey[700] : Colors.grey[500]),
                  ),
                ],
              ),
            ),
            if (isUnlocked)
              IconButton(
                onPressed: () => _handleRedeem(reward, product),
                icon: Icon(Icons.arrow_forward, color: yellowColor),
              ),
          ],
        ),
      ),
    );
  }
}