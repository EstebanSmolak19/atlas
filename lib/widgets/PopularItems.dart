import 'package:atlas/models/AppRoutes.dart';
import 'package:atlas/providers/ProductProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PopularItems extends StatefulWidget {
  const PopularItems({super.key});

  @override
  State<PopularItems> createState() => _PopularItemsState();
}

class _PopularItemsState extends State<PopularItems> {
  final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchPopularItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final items = productProvider.popularItems;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (productProvider.isLoading) {
      return SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator(color: isDark ? yellowColor : Colors.black)),
      );
    }

    if (items.isEmpty) {
      return const SizedBox(
        height: 250,
        child: Center(child: Text("Aucun produit populaire")),
      );
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 25),
        itemBuilder: (context, index) {
          final item = items[index];

          return SizedBox(
            width: 160,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 45,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.only(top: 105, left: 12, bottom: 0, right: 12),
                    decoration: BoxDecoration(
                      color: yellowColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // Le texte reste noir sur le jaune
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time_filled, color: Colors.black, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              "${item.time} min",
                              style: const TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.star, color: Colors.black, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              "${item.average}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.detailPage, arguments: item);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Colors.black : Colors.white,
                            foregroundColor: isDark ? yellowColor : Colors.black,
                            elevation: 0,
                            minimumSize: const Size(double.infinity, 38),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "${item.price.toStringAsFixed(2)}€",
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                Positioned(
                  top: 0,
                  width: 160,
                  child: Center(
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/${item.img_url}',
                        height: 140,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Image.asset('assets/pizza1.png', height: 140),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}