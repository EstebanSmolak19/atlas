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
  final Color yellowColor = const Color.fromARGB(255, 250, 215, 109);
  final Color grayColor = const Color.fromARGB(255, 51, 41, 38).withOpacity(0.6);

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
    final items = productProvider.products;

    if (productProvider.isLoading) {
      return const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator(color: Colors.black)),
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
                          color: Colors.grey.withOpacity(0.1),
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
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time_filled, color: Colors.black, size: 16),
                            const SizedBox(width: 4), 

                            Text(
                              "${item.time.toString()} min", 
                              style: TextStyle(
                                color: grayColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      
                            const SizedBox(width: 10), 
                            const Icon(Icons.star, color: Color.fromARGB(255, 255, 191, 0), size: 16),
                            const SizedBox(width: 4), 

                            Text(
                              "${item.average}",
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.detailPage, arguments: item);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            minimumSize: const Size(double.infinity, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "${item.prize.toString()}€",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
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
                        'assets/pizza1.png', 
                        fit: BoxFit.contain),
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