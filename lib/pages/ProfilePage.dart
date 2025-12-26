import 'package:atlas/pages/FirstPage.dart';
import 'package:atlas/providers/UserProvider.dart';
import 'package:atlas/widgets/customAppbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

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
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    final String userEmail = user?.email ?? "";
    final String userName = user?.pseudo ?? "";

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
                child: Image.asset(
                  'assets/burger1.png',
                  width: 300,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -80,
            child: Transform.rotate(
              angle: -0.5,
              child: Opacity(
                opacity: 0.08,
                child: Image.asset(
                  'assets/pizza1.png',
                  width: 250,
                ),
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
                        color: yellowColor,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50),
                        ),
                        image: DecorationImage(
                          image: const AssetImage('assets/icon-burger.png'),
                          colorFilter: ColorFilter.mode(
                              Colors.white.withOpacity(0.15), BlendMode.srcIn),
                          repeat: ImageRepeat.repeat,
                          scale: 4.0,
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
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                  ),
                                  child: const Text("🍔", style: TextStyle(fontSize: 16)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          Column(
                              children: [
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  userEmail,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black.withOpacity(0.6),
                                  ),
                                ),
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
                          image: const DecorationImage(
                            image: AssetImage('assets/burger1.png'),
                            opacity: 0.2,
                            alignment: Alignment.centerRight,
                            fit: BoxFit.contain,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
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
                                    const Text(
                                      "2,450 pts",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 34,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Prochaine récompense : Menu XL offert !",
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: 0.8,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(yellowColor),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildQuickActionCard(Icons.fastfood, "Mes\nCommandes", isMain: true),
                          _buildQuickActionCard(Icons.favorite_rounded, "Plats\nFavoris"),
                          _buildQuickActionCard(Icons.confirmation_number, "Mes\nCoupons"),
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
                            _buildSettingsTile(Icons.person_outline, "Informations Personnelles"),
                            _buildDivider(),
                            _buildSettingsTile(Icons.location_on_outlined, "Mes Adresses"),
                            _buildDivider(),
                            _buildSettingsTile(Icons.payment_outlined, "Moyens de paiement"),
                            _buildDivider(),
                            _buildSettingsTile(Icons.support_agent, "Aide & Support"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      TextButton(
                        onPressed: () async {
                          await Provider.of<UserProvider>(context, listen: false).logout();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const FirstPage()),
                              (route) => false,
                            );
                          }
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

  Widget _buildQuickActionCard(IconData icon, String label, {bool isMain = false}) {
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
          onTap: () {},
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

  Widget _buildSettingsTile(IconData icon, String title) {
    return ListTile(
      onTap: () {},
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