import 'package:atlas/widgets/QtyBtn.dart';
import 'package:atlas/widgets/appbar/detailAppBar.dart';
import 'package:atlas/widgets/infoBadge.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int quantity = 1;
  final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: yellowColor,
      appBar: const DetailAppBar(),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.6), 
                    yellowColor,
                  ],
                  center: Alignment.center,
                  radius: 0.53,
                ),
              ),
              child: Image.asset(
                'assets/pizza1.png', 
                fit: BoxFit.contain,
              ),
            ),
          ),

          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Pizza Royale",
                        style: GoogleFonts.lilitaOne(
                          fontSize: 28,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "19.90 £",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: yellowColor,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      buildInfoBadge(Icons.star, "4.8", Colors.orange),
                      const SizedBox(width: 20),
                      buildInfoBadge(Icons.local_fire_department, "520 kcal", Colors.redAccent),
                      const SizedBox(width: 20),
                      buildInfoBadge(Icons.access_time_filled, "25 min", Colors.blueGrey),
                    ],
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Une délicieuse pizza garnie de jambon, champignons frais, olives noires et d'une généreuse couche de mozzarella fondante. Un classique indémodable pour les gourmands !",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),

                  const Spacer(),

                  Row(
                    children: [
                      // Sélecteur de quantité (- 1 +)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            buildQtyBtn(Icons.remove, () {
                              if (quantity > 1) setState(() => quantity--);
                            }),
                            SizedBox(
                              width: 40,
                              child: Text(
                                "$quantity",
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                            buildQtyBtn(Icons.add, () {
                              setState(() => quantity++);
                            }),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 20),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            "Ajouter au panier",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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
    );
  }
}