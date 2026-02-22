import 'package:atlas/models/UserModel.dart';
import 'package:atlas/providers/FavoriteProvider.dart';
import 'package:atlas/providers/ProductProvider.dart';
import 'package:atlas/providers/CategoryProvider.dart';
import 'package:atlas/services/UserService.dart';
import 'package:atlas/widgets/FoodCategoryNavBar.dart';
import 'package:atlas/widgets/PopularItems.dart';
import 'package:atlas/widgets/TitleSection.dart';
import 'package:atlas/widgets/appbar/customAppbar.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UserService _userService = UserService();
  final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);

  Key _refreshKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavoriteProvider>(context, listen: false).fetchFavorites();
    });
  }

  Future<void> _handleRefresh() async {
    try {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

      await Future.wait([
        productProvider.refreshPopularItems(),
        categoryProvider.refreshCategories(),
      ]).timeout(const Duration(seconds: 10));

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Connexion instable. Les données n'ont pas pu être actualisées."),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(label: "OK", textColor: Colors.white, onPressed: () {}),
          ),
        );
      }
    }
  }

  void _retryConnection() {
    setState(() {
      _refreshKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(),
      body: FutureBuilder<UserModel?>(
        key: _refreshKey,
        future: _userService.getCurrentUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: isDark ? yellowColor : Colors.black));
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return _buildErrorState(isDark);
          }

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            color: isDark ? yellowColor : Colors.black,
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleSection(title: 'Découverte'),
                    const SizedBox(height: 15),
                    _buildHeroPromotion(),
                    const SizedBox(height: 15),
                    _buildPageIndicator(isDark),
                    const FoodCategoryNavBar(),
                    const SizedBox(height: 20),
                    TitleSection(title: 'Produits populaires', size: 18),
                    const PopularItems(),
                    const SizedBox(height: 150),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: yellowColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wifi_off_rounded, size: 80, color: yellowColor),
            ),
            const SizedBox(height: 30),
            Text(
              "Atlas est hors-ligne",
              style: GoogleFonts.lilitaOne(fontSize: 28, color: isDark ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 15),
            Text(
              "Impossible de contacter nos cuisines. Vérifie ta connexion internet pour continuer l'exploration.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _retryConnection,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("RÉESSAYER", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? yellowColor : Colors.black,
                foregroundColor: isDark ? Colors.black : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroPromotion() {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            color: yellowColor,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 27, top: 20, bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Burgers Express", style: GoogleFonts.lilitaOne(fontSize: 20, letterSpacing: 2.5, color: const Color.fromARGB(255, 51, 41, 38).withOpacity(0.6), height: 1.0)),
                        const SizedBox(height: 10),
                        Text("-30% ICI", style: GoogleFonts.titanOne(fontSize: 35, color: Colors.brown[900], height: 1.0)),
                        const SizedBox(height: 5),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 30),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),

                          child: const Text("Commander", style: TextStyle(fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(flex: 2, child: Container()),
              ],
            ),
          ),
          Positioned(
            left: 45, bottom: -20, width: 500,
            child: Stack(
              children: [
                Transform.translate(
                  offset: const Offset(5, 8),
                  child: ImageFiltered(
                    imageFilter: ui.ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                    child: Image.asset('assets/burger/burger1.png', fit: BoxFit.contain, color: Colors.black.withOpacity(0.4), colorBlendMode: BlendMode.srcIn),
                  ),
                ),
                Image.asset('assets/burger/burger1.png', fit: BoxFit.contain),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 25, height: 8, decoration: BoxDecoration(color: yellowColor, borderRadius: BorderRadius.circular(10))),
          const SizedBox(width: 5),
          Container(width: 8, height: 8, decoration: BoxDecoration(color: isDark ? Colors.white12 : Colors.grey.shade300, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Container(width: 8, height: 8, decoration: BoxDecoration(color: isDark ? Colors.white12 : Colors.grey.shade300, shape: BoxShape.circle)),
        ],
      ),
    );
  }
}