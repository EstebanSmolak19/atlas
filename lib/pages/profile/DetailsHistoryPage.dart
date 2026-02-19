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

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBg = Theme.of(context).cardColor;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.white70 : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: yellowColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)
            ]
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? yellowColor : Colors.black, size: 20),
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

          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
                boxShadow: [
                  if (isDark)
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, -5))
                ]
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 15),
                        width: 50, height: 5,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white12 : Colors.grey[200],
                          borderRadius: BorderRadius.circular(10)
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Votre commande",
                            style: GoogleFonts.lilitaOne(fontSize: 20, color: textColor)
                          ),
                          Text(
                            "${order.date.day}/${order.date.month}/${order.date.year}",
                            style: TextStyle(color: subTextColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(25),
                        itemCount: order.items.length,
                        separatorBuilder: (ctx, i) => Divider(height: 30, color: isDark ? Colors.white10 : Colors.grey[100]),
                        itemBuilder: (context, index) {
                          final item = order.items[index];
                          final String details = item['details'] ?? "";
                          final bool isMenu = item['name'].toString().startsWith("Menu");

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 60, height: 60,
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF9F9F9),
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

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: textColor),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Qté: ${item['quantity']}",
                                      style: TextStyle(color: subTextColor, fontWeight: FontWeight.w600),
                                    ),
                                    if (isMenu && details.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          details,
                                          style: TextStyle(
                                            color: isDark ? Colors.white60 : Colors.grey[700],
                                            fontSize: 12,
                                            height: 1.4
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              Text(
                                "${(item['price'] * item['quantity']).toStringAsFixed(2)}€",
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textColor),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    // BOUTON TICKET (Adaptatif)
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
                          icon: Icon(Icons.receipt_long, color: isDark ? yellowColor : Colors.black),
                          label: Text(
                            "VOIR LE TICKET DE CAISSE",
                            style: TextStyle(
                              color: isDark ? yellowColor : Colors.black,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1
                            )
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: isDark ? yellowColor : Colors.black, width: 2),
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