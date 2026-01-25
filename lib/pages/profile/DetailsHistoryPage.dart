import 'package:atlas/models/HistoryModel.dart';
import 'package:atlas/pages/profile/TicketHistoryPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailsHistoryPage extends StatelessWidget {
  final HistoryModel order;

  const DetailsHistoryPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);

    return Scaffold(
      backgroundColor: yellowColor, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)
            ]
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          "Détails",
          style: GoogleFonts.lilitaOne(color: Colors.black, fontSize: 24),
        ),
      ),
      body: Column(
        children: [
          // EN-TÊTE (Montant + Statut)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Text(
                  "Total payé",
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "${order.total.toStringAsFixed(2)}€",
                  style: GoogleFonts.lilitaOne(fontSize: 48, color: Colors.black),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _getStatusIcon(order.status),
                      const SizedBox(width: 8),
                      Text(
                        order.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // LISTE DES ARTICLES (Carte blanche)
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
                child: Column(
                  children: [
                    // Barre de tiret décorative
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 15),
                        width: 50, height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10)
                        ),
                      ),
                    ),
                    
                    // Titre section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Votre commande", style: GoogleFonts.lilitaOne(fontSize: 20)),
                          Text(
                            "${order.date.day}/${order.date.month}/${order.date.year}",
                            style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(25),
                        itemCount: order.items.length,
                        separatorBuilder: (ctx, i) => Divider(height: 30, color: Colors.grey[100]),
                        itemBuilder: (context, index) {
                          final item = order.items[index];
                          return Row(
                            children: [
                              // Image produit
                              Container(
                                width: 60, height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9F9F9),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(
                                    'assets/${item['img_url'] ?? "pizza1.png"}', 
                                    fit: BoxFit.contain,
                                    errorBuilder: (ctx, err, stack) => Image.asset('assets/pizza1.png'),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              
                              // Infos
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Qté: ${item['quantity']}",
                                      style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Prix
                              Text(
                                "${(item['price'] * item['quantity']).toStringAsFixed(2)}€",
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    
                    // BOUTON TICKET
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25, 0, 25, 30),
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TicketHistoryPage(order: order),
                              ),
                            );
                          },
                          icon: const Icon(Icons.receipt_long, color: Colors.black),
                          label: const Text("VOIR LE TICKET DE CAISSE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.black, width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'En préparation': return Colors.orange;
      case 'Livrée': return Colors.green;
      case 'Annulée': return Colors.red;
      default: return Colors.blue;
    }
  }
  
  Widget _getStatusIcon(String status) {
    IconData icon;
    switch (status) {
      case 'En préparation': icon = Icons.outdoor_grill; break;
      case 'Livrée': icon = Icons.check_circle; break;
      case 'Annulée': icon = Icons.cancel; break;
      default: icon = Icons.info;
    }
    return Icon(icon, color: Colors.white, size: 16);
  }
}