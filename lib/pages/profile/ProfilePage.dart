import 'package:atlas/models/AppRoutes.dart';
import 'package:atlas/models/RewardModel.dart';
import 'package:atlas/pages/profile/SubscriptionPage.dart';
import 'package:atlas/providers/CommandeProvider.dart';
import 'package:atlas/providers/NavigationProvider.dart';
import 'package:atlas/providers/RewardProvider.dart';
import 'package:atlas/providers/UserProvider.dart';
import 'package:atlas/widgets/appbar/customAppbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);

  @override
  void initState() {
    super.initState();
    _refreshAllData();
  }

  Future<void> _refreshAllData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final commandeProvider = Provider.of<Commandeprovider>(context, listen: false);
    final rewardProvider = Provider.of<RewardProvider>(context, listen: false);

    await userProvider.loadUser();
    if (userProvider.user != null) {
      commandeProvider.updateUser(userProvider.user);
    }
    await rewardProvider.fetchRewards();
  }

  String _getPlanName(String? planId) {
    switch (planId) {
      case 'basic': return 'NOMAD';
      case 'standard': return 'EXPLORER';
      case 'premium': return 'ELITE';
      default: return 'PREMIUM';
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final commandeProvider = Provider.of<Commandeprovider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text(
          "Supprimer le compte ?",
          style: GoogleFonts.lilitaOne(color: isDark ? Colors.white : Colors.black)
        ),
        content: const Text(
          "Attention : Cette action est irréversible. Vous perdrez définitivement vos points de fidélité, vos avantages Premium et l'historique de vos commandes.",
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ANNULER", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await userProvider.deleteAccount();
                commandeProvider.clearCart();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Pour votre sécurité, veuillez vous reconnecter avant de supprimer votre compte."),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text("SUPPRIMER", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getTiersFromRewards(List<RewardModel> rewards) {
    final Map<int, String> tiers = {};
    for (var reward in rewards) {
      if (!tiers.containsKey(reward.cost)) {
        tiers[reward.cost] = _getTierName(reward.cost);
      }
    }
    final List<Map<String, dynamic>> tiersList = [];
    final sortedCosts = tiers.keys.toList()..sort();
    for (var cost in sortedCosts) {
      tiersList.add({'points': cost, 'name': tiers[cost]});
    }
    return tiersList;
  }

  String _getTierName(int cost) {
    if (cost <= 50) return "L'Explorateur";
    if (cost <= 150) return "Le Gourmand";
    if (cost <= 300) return "L'Aventurier";
    if (cost <= 500) return "Le Conquérant";
    return "L'Empereur";
  }

  Map<String, dynamic>? _getNextTier(int currentPoints, List<Map<String, dynamic>> tiers) {
    for (var tier in tiers) {
      if (currentPoints < tier['points']) return tier;
    }
    return null;
  }

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

  double _getProgressToNextTier(int currentPoints, List<Map<String, dynamic>> tiers) {
    final lastTier = _getLastReachedTier(currentPoints, tiers);
    final nextTier = _getNextTier(currentPoints, tiers);
    if (nextTier == null) return 1.0;
    final int startPoints = lastTier?['points'] ?? 0;
    final int endPoints = nextTier['points'];
    final int progress = currentPoints - startPoints;
    final int total = endPoints - startPoints;
    return progress / total;
  }

  Widget _buildProgressSection(int displayedPoints, List<Map<String, dynamic>> tiers) {
    if (tiers.isEmpty) {
      return const Text("Aucun palier disponible", style: TextStyle(color: Colors.white70, fontSize: 13));
    }
    final nextTier = _getNextTier(displayedPoints, tiers);
    final lastReachedTier = _getLastReachedTier(displayedPoints, tiers);
    final progress = _getProgressToNextTier(displayedPoints, tiers);
    final allTiersReached = nextTier == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (lastReachedTier != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.emoji_events, color: yellowColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  "Palier atteint : ${lastReachedTier['name']}",
                  style: TextStyle(color: yellowColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
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
                const Expanded(
                  child: Text("🎉 Félicitations ! Vous avez atteint tous les paliers !", style: TextStyle(color: Color.fromARGB(255, 242, 202, 80), fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Prochain palier : ${nextTier!['name']}", style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text("${nextTier['points'] - displayedPoints} pts restants", style: TextStyle(color: yellowColor, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Stack(
                children: [
                  Container(height: 12, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10))),
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [yellowColor, yellowColor.withOpacity(0.7)]),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: yellowColor.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
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
    final rewardProvider = context.watch<RewardProvider>();
    final user = userProvider.user;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final Color cardBg = Theme.of(context).cardColor;
    final Color dividerColor = Theme.of(context).dividerColor;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.black)));
    }

    final String planName = _getPlanName(user.planId);
    final int safeDisplayedPoints = commandeProvider.availablePoints;
    final bool hasUsedPoints = user.points != safeDisplayedPoints;
    final List<Map<String, dynamic>> rewardTiers = _getTiersFromRewards(rewardProvider.rewards);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          Positioned(
            top: 0, right: -80,
            child: Transform.rotate(angle: 0.2, child: Opacity(opacity: isDark ? 0.05 : 0.1, child: Image.asset('assets/burger1.png', width: 300))),
          ),

          RefreshIndicator(
            onRefresh: _refreshAllData,
            color: yellowColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // HEADER
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 240,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: user.premium ? Colors.black : yellowColor,
                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
                        ),
                      ),
                      Positioned(
                        top: 50,
                        child: Column(
                          children: [
                            Container(
                              width: 130, height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: isDark ? Colors.grey[900]! : Colors.white, width: 6),
                                image: const DecorationImage(image: NetworkImage("https://i.pravatar.cc/300"), fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(user.pseudo, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: user.premium ? Colors.white : Colors.black)),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: user.premium ? yellowColor : (isDark ? Colors.white12 : Colors.black12), borderRadius: BorderRadius.circular(20)),
                              child: Text(user.premium ? "MEMBRE $planName" : "MEMBRE CLASSIQUE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: user.premium ? Colors.black : (isDark ? Colors.white70 : Colors.black54))),
                            )
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
                        _buildSubscriptionCard(user, planName, isDark, cardBg),
                        const SizedBox(height: 25),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E1E) : Colors.black,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("BURGER CLUB", style: TextStyle(color: yellowColor, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
                              const SizedBox(height: 5),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text("$safeDisplayedPoints pts", style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900)),
                                  if (hasUsedPoints) Padding(padding: const EdgeInsets.only(bottom: 8, left: 10), child: Text("sur ${user.points} pts", style: const TextStyle(color: Colors.white70, fontSize: 14, decoration: TextDecoration.lineThrough))),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _buildProgressSection(safeDisplayedPoints, rewardTiers),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildQuickActionCard(Icons.fastfood, "Mes\nCommandes", AppRoutes.history, cardBg, isDark),
                            _buildQuickActionCard(Icons.people_alt_rounded, "Amis &\nCommunauté", AppRoutes.friends, cardBg, isDark, isMain: true),
                            _buildQuickActionCard(Icons.favorite_rounded, "Plats\nFavoris", AppRoutes.favorite, cardBg, isDark),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // PARAMÈTRES
                        Container(
                          decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(24)),
                          child: Column(
                            children: [
                              _buildSettingsTile(Icons.location_on_outlined, "Mes Adresses", AppRoutes.address, isDark),
                              _buildDivider(dividerColor),
                              _buildSettingsTile(Icons.support_agent, "Aide & Support", AppRoutes.support, isDark),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // BOUTONS D'ACTION
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    await userProvider.logout();
                                    commandeProvider.clearCart();
                                    if (context.mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
                                  },
                                  icon: const Icon(Icons.logout_rounded, size: 20),
                                  label: const Text("SE DÉCONNECTER", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark ? Colors.white10 : Colors.white,
                                    foregroundColor: isDark ? Colors.white70 : Colors.black87,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              GestureDetector(
                                onTap: () => _showDeleteAccountDialog(context),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.delete_forever_outlined, size: 18, color: Colors.red[300]),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Supprimer définitivement mon compte",
                                      style: TextStyle(
                                        color: Colors.red[300],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 130),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(dynamic user, String planName, bool isDark, Color cardBg) {
    if (user.premium) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: yellowColor.withOpacity(0.8), width: 1.5),
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
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionPage())),
              child: Text("Gérer", style: TextStyle(color: isDark ? yellowColor : Colors.black, fontWeight: FontWeight.bold)),
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
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionPage())),
                    style: ElevatedButton.styleFrom(backgroundColor: yellowColor, foregroundColor: Colors.black, minimumSize: const Size(0, 35)),
                    child: const Text("S'abonner", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  )
                ],
              ),
            ),
            Icon(Icons.diamond_outlined, color: yellowColor.withOpacity(0.3), size: 70),
          ],
        ),
      );
    }
  }

  Widget _buildQuickActionCard(IconData icon, String label, String routeString, Color cardBg, bool isDark, {bool isMain = false}) {
    return Container(
      width: 105, height: 110,
      decoration: BoxDecoration(
        color: isMain ? yellowColor : cardBg,
        borderRadius: BorderRadius.circular(24),
        border: isDark && !isMain ? Border.all(color: Colors.white10) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            if (routeString == AppRoutes.favorite) context.read<NavigationProvider>().setIndex(1);
            else if (routeString.isNotEmpty) Navigator.pushNamed(context, routeString);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isMain ? Colors.black : (isDark ? Colors.white : Colors.black), size: 28),
              const SizedBox(height: 12),
              Text(label, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, height: 1.1, color: isMain ? Colors.black : (isDark ? Colors.white : Colors.black))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String route, bool isDark) {
    return ListTile(
      onTap: () => Navigator.pushNamed(context, route),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey[100], shape: BoxShape.circle),
        child: Icon(icon, color: isDark ? Colors.white70 : Colors.black87, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: Icon(Icons.arrow_forward_ios, size: 12, color: isDark ? Colors.white54 : Colors.black),
    );
  }

  Widget _buildDivider(Color color) {
    return Divider(height: 1, thickness: 1, color: color, indent: 70, endIndent: 20);
  }
}