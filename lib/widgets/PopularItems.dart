import 'package:atlas/models/AppRoutes.dart';
import 'package:flutter/material.dart';

class PopularItems extends StatefulWidget {
  const PopularItems({super.key});

  @override
  State<PopularItems> createState() => _PopularItemsState();
}

class _PopularItemsState extends State<PopularItems> {
  final Color yellowColor = const Color.fromARGB(255, 250, 215, 109);
  final Color grayColor = Color.fromARGB(255, 51, 41, 38).withOpacity(0.6);

  final List<Map<String, dynamic>> items = [
    {'icon': "assets/pizza1.png", 'label': "Pizza Royale", 'note': 4.5, 'price': "19.90"},
    {'icon': "assets/pizza1.png", 'label': "Pizza Cheese", 'note': 4.7, 'price': "17.99"},
    {'icon': "assets/pizza1.png", 'label': "Burger King", 'note': 4.2, 'price': "10.99"},
    {'icon': "assets/pizza1.png", 'label': "Burger King", 'note': 3.9, 'price': "11.99"},
  ];

  @override
  Widget build(BuildContext context) {
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
                
                // CARD
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
                          item['label'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time_filled, color: Colors.black, size: 16),
                            const SizedBox(width: 4), 

                            Text(
                              "21 min", 
                              style: TextStyle(
                                color: grayColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      
                            const SizedBox(width: 10), 
                            const Icon(Icons.star, color: Color.fromARGB(255, 255, 191, 0), size: 16),
                            const SizedBox(width: 4), 

                            Text(
                              "${item['note']}",
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.detailPage);
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
                            item['price'] + '£',
                            style: TextStyle(
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
                        item['icon'],
                        fit: BoxFit.contain,
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