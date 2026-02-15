import 'package:atlas/models/AppRoutes.dart';
import 'package:atlas/models/RewardModel.dart';
import 'package:atlas/pages/profile/SubscriptionPage.dart';
import 'package:atlas/providers/CommandeProvider.dart';
import 'package:atlas/providers/NavigationProvider.dart';
import 'package:atlas/providers/RewardProvider.dart';
import 'package:atlas/providers/UserProvider.dart';
import 'package:atlas/widgets/appbar/customAppbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);
  final Color scaffoldColor = const Color(0xFFF9F9F9);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).loadUser();
      Provider.of<RewardProvider>(context, listen: false).fetchRewards(); // AJOUTÉ
    });
  }

  String _getPlanName(String? planId) {
    switch (planId) {
      case 'basic': return 'NOMAD';
      case 'standard': return 'EXPLORER';
      case 'premium': return 'ELITE';
      default: return 'PREMIUM';
    }
  }

  // Génère la liste des paliers à partir des rewards
  List<Map<String, dynamic>> _getTiersFromRewards(List<RewardModel> rewards) {
    // Grouper les rewards par coût et créer les paliers
    final Map<int, String> tiers = {};

    for (var reward in rewards) {
      if (!tiers.containsKey(reward.cost)) {
        tiers[reward.cost] = _getTierName(reward.cost);
      }
    }

    // Convertir en liste triée
    final List<Map<String, dynamic>> tiersList = [];
    final sortedCosts = tiers.keys.toList()..sort();

    for (var cost in sortedCosts) {
      tiersList.add({
        'points': cost,
        'name': tiers[cost],
      });
    }

    return tiersList;
  }

  // Même logique que dans RewardPage
  String _getTierName(int cost) {
    if (cost <= 50) return "L'Explorateur";
    if (cost <= 150) return "Le Gourmand";
    if (cost <= 300) return "L'Aventurier";
    if (cost <= 500) return "Le Conquérant";
    return "L'Empereur";
  }

  // Trouve le prochain palier
  Map<String, dynamic>? _getNextTier(int currentPoints, List<Map<String, dynamic>> tiers) {
    for (var tier in tiers) {
      if (currentPoints < tier['points']) {
        return tier;
      }
    }
    return null;
  }

  // Trouve le dernier palier atteint
  Map<String, dynamic>? _getLastReachedTier(int currentPoints, List<Map<String, dynamic>> tiers) {
    Map<String, dynamic>? lastTier;
    for (var tier in tiers) {
      if (currentPoints >= tier['points']) {
        lastTier = tier;
      } else {
        break;
      }
    }
    return lastTier;
  }

  // Calcule la progression vers le prochain palier
  double _getProgressToNextTier(int currentPoints, List<Map<String, dynamic>> tiers) {
    final lastTier = _getLastReachedTier(currentPoints, tiers);
    final nextTier = _getNextTier(currentPoints, tiers);

    if (nextTier == null) {
      return 1.0; 
    }

    final int startPoints = lastTier?['points'] ?? 0;
    final int endPoints = nextTier['points'];
    final int progress = currentPoints - startPoints;
    final int total = endPoints - startPoints;

    return progress / total;
  }

  Widget _buildProgressSection(int displayedPoints, List<Map<String, dynamic>> tiers) {
    if (tiers.isEmpty) {
      return const Text(
        "Aucun palier disponible",
        style: TextStyle(color: Colors.white70, fontSize: 13),
      );
    }

    final nextTier = _getNextTier(displayedPoints, tiers);
    final lastReachedTier = _getLastReachedTier(displayedPoints, tiers);
    final progress = _getProgressToNextTier(displayedPoints, tiers);
    final allTiersReached = nextTier == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Texte du dernier palier atteint
        if (lastReachedTier != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.emoji_events, color: yellowColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  "Palier atteint : ${lastReachedTier['name']}",
                  style: TextStyle(
                    color: yellowColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

        // Message si tous les paliers sont atteints
        if (allTiersReached)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: yellowColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: yellowColor, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(Icons.stars, color: yellowColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "🎉 Félicitations ! Vous avez atteint tous les paliers !",
                    style: TextStyle(
                      color: yellowColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Texte du prochain palier
              Text(
                "Prochain palier : ${nextTier!['name']}",
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                "${nextTier['points'] - displayedPoints} pts restants",
                style: TextStyle(
                  color: yellowColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // Barre de progression
              Stack(
                children: [
                  // Fond de la barre
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // Progression
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [yellowColor, yellowColor.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: yellowColor.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Indicateur de progression en %
                  if (progress > 0.15)
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            "${(progress * 100).toInt()}%",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Points de début et de fin
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${lastReachedTier?['points'] ?? 0} pts",
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${nextTier['points']} pts",
                    style: TextStyle(
                      color: yellowColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final commandeProvider = context.watch<Commandeprovider>();
    final rewardProvider = context.watch<RewardProvider>(); // AJOUTÉ
    final user = userProvider.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.black)));
    }

    final String planName = _getPlanName(user.planId);
    final int displayedPoints = commandeProvider.availablePoints;
    final bool hasUsedPoints = user.points != displayedPoints;
    final List<Map<String, dynamic>> rewardTiers = _getTiersFromRewards(rewardProvider.rewards); // AJOUTÉ

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: -80,
            child: Transform.rotate(
              angle: 0.2,
              child: Opacity(
                opacity: 0.1,
                child: Image.asset('assets/burger1.png', width: 300),
              ),
            ),
          ),

          SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 240,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: user.premium ? Colors.black : yellowColor,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 50,
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 25,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                  image: const DecorationImage(
                                    image: NetworkImage("https://i.pravatar.cc/300"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: user.premium ? yellowColor : Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                  ),
                                  child: Icon(
                                    user.premium ? Icons.star : Icons.lunch_dining,
                                    size: 20,
                                    color: Colors.black
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          Column(
                            children: [
                              Text(
                                user.pseudo,
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: user.premium ? Colors.white : Colors.black,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: user.premium ? yellowColor : Colors.black12,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  user.premium ? "MEMBRE $planName" : "MEMBRE CLASSIQUE",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: user.premium ? Colors.black : Colors.black54,
                                    letterSpacing: 1
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildSubscriptionCard(user, planName),
                      const SizedBox(height: 25),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "BURGER CLUB",
                              style: TextStyle(
                                color: yellowColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "$displayedPoints pts",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                if (hasUsedPoints) ...[
                                  const SizedBox(width: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      "sur ${user.points} pts",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (hasUsedPoints)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: yellowColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: yellowColor, width: 1),
                                  ),
                                  child: Text(
                                    "${user.points - displayedPoints} pts utilisés dans le panier",
                                    style: TextStyle(
                                      color: yellowColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),
                            _buildProgressSection(displayedPoints, rewardTiers),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildQuickActionCard(
                            Icons.fastfood,
                            "Mes\nCommandes",
                            AppRoutes.history,
                          ),
                          _buildQuickActionCard(
                            Icons.favorite_rounded,
                            "Plats\nFavoris",
                            AppRoutes.favorite,
                            isMain: true,
                          ),
                          _buildQuickActionCard(
                            Icons.confirmation_number,
                            "Mes\nCoupons",
                            ''
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildSettingsTile(Icons.location_on_outlined, "Mes Adresses", AppRoutes.address),
                            _buildDivider(),
                            _buildSettingsTile(Icons.payment_outlined, "Moyens de paiement", '/payment'),
                            _buildDivider(),
                            _buildSettingsTile(Icons.support_agent, "Aide & Support", AppRoutes.support),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      TextButton(
                        onPressed: () async {
                          await userProvider.logout();
                          commandeProvider.clearCart();
                          if (context.mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
                        },
                        child: Text(
                          "Se déconnecter",
                          style: TextStyle(
                            color: Colors.red[400],
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 130),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(dynamic user, String planName) {
    if (user.premium) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: yellowColor.withOpacity(0.8), width: 1.5),
          boxShadow: [
            BoxShadow(color: yellowColor.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
          ]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: yellowColor.withOpacity(0.2), shape: BoxShape.circle),
                  child: Icon(Icons.star, color: Colors.orange[800], size: 20),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Plan $planName Actif", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    const Text("Avantages débloqués", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SubscriptionPage()),
                );
              },
              child: const Text("Gérer", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Colors.black, Color(0xFF333333)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))
          ]
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("PASSEZ PREMIUM", style: TextStyle(color: yellowColor, fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 12)),
                  const SizedBox(height: 5),
                  const Text("Livraison offerte & remises", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SubscriptionPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: yellowColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      minimumSize: const Size(0, 35),
                    ),
                    child: const Text("S'abonner", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  )
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.diamond_outlined, color: yellowColor.withOpacity(0.3), size: 70),
          ],
        ),
      );
    }
  }

  Widget _buildQuickActionCard(IconData icon, String label, String routeString, {bool isMain = false}) {
    return Container(
      width: 105,
      height: 110,
      decoration: BoxDecoration(
        color: isMain ? yellowColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isMain ? yellowColor.withOpacity(0.4) : Colors.grey.withOpacity(0.05),
            blurRadius: isMain ? 15 : 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            if (routeString == AppRoutes.favorite) {
              context.read<NavigationProvider>().setIndex(1);
            }
            else if (routeString.isNotEmpty) {
              Navigator.pushNamed(context, routeString);
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.black,
                size: 28,
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  height: 1.1,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String route) {
    return ListTile(
      onTap: () => Navigator.pushNamed(context, route),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.black),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey[100], indent: 70, endIndent: 20);
  }
}