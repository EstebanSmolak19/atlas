import 'package:atlas/models/AppRoutes.dart';
import 'package:atlas/models/ProductModel.dart';
import 'package:atlas/providers/FavoriteProvider.dart';
import 'package:atlas/providers/CommandeProvider.dart';
import 'package:atlas/widgets/appbar/customAppbar.dart';
import 'package:atlas/widgets/login/Toast.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final Color yellowColor = const Color(0xFFF2CA50);

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      Provider.of<FavoriteProvider>(context, listen: false).fetchFavorites()
    );
  }

  @override
  Widget build(BuildContext context) {
    final favProvider = context.watch<FavoriteProvider>();
    final cartProvider = context.read<Commandeprovider>();
    final favorites = favProvider.favoriteProducts;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(),
      body: favorites.isEmpty
          ? _buildEmptyState(isDark)
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              itemCount: favorites.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final product = favorites[index];
                return _buildAtlasFavoriteCard(product, favProvider, cartProvider, isDark);
              },
            ),
    );
  }

  Widget _buildAtlasFavoriteCard(ProductModel product, FavoriteProvider favProvider, Commandeprovider cartProvider, bool isDark) {
    final Color cardColor = Theme.of(context).cardColor;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.white70 : Colors.grey[600]!;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.detailPage, arguments: product);
      },
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // 1. ZONE IMAGE
                Container(
                  width: 130,
                  decoration: BoxDecoration(
                    color: yellowColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: -20,
                        left: -20,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Hero(
                          tag: "fav_${product.name}",
                          child: Image.asset(
                            'assets/${product.img_url}',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Image.asset('assets/burger1.png'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. ZONE INFOS
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: textColor,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              product.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: subTextColor,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${product.price.toStringAsFixed(2)}€",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: textColor,
                              ),
                            ),

                            GestureDetector(
                              onTap: () {
                                cartProvider.addItem(product, 1);
                                Toast.show(context, "Ajouté au panier !");
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? yellowColor : Colors.black,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.add_shopping_cart, size: 14, color: isDark ? Colors.black : Colors.white),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Ajouter",
                                      style: GoogleFonts.lilitaOne(
                                        color: isDark ? Colors.black : Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Bouton Supprimer
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  favProvider.toggleFavorite(product);
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 16, color: isDark ? Colors.white54 : Colors.grey[400]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: yellowColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
              Icon(Icons.bookmark_border, size: 60, color: textColor.withOpacity(0.8)),
            ],
          ),
          const SizedBox(height: 25),
          Text(
            "Ta collection est vide !",
            style: GoogleFonts.lilitaOne(fontSize: 24, color: textColor),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Text(
              "Les explorateurs Atlas gardent toujours leurs meilleures découvertes ici.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontSize: 15,
                height: 1.5,
                fontWeight: FontWeight.w500
              ),
            ),
          ),
          const SizedBox(height: 35),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? yellowColor : Colors.black,
              foregroundColor: isDark ? Colors.black : yellowColor,
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.3),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "VOIR LA CARTE",
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          )
        ],
      ),
    );
  }
}