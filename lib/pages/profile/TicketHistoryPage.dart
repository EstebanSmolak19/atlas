import 'package:atlas/models/HistoryModel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TicketHistoryPage extends StatelessWidget {
  final HistoryModel order;

  const TicketHistoryPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final Color ticketBg = Theme.of(context).cardColor;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.white54 : Colors.grey[700]!;
    final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
            decoration: BoxDecoration(
              color: isDark ? ticketBg : const Color(0xFFFDFDFD),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10)
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.restaurant, size: 40, color: isDark ? yellowColor : Colors.black),
                const SizedBox(height: 10),
                Text(
                  "ATLAS FOOD",
                  style: GoogleFonts.courierPrime(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  )
                ),
                Text(
                  "21 Boulevard du NullPointer",
                  style: GoogleFonts.courierPrime(fontSize: 12, color: subTextColor)
                ),
                Text(
                  "Tel: 01 00 00 11 21",
                  style: GoogleFonts.courierPrime(fontSize: 12, color: subTextColor)
                ),

                const SizedBox(height: 30),

                _buildDashedLine(isDark ? Colors.white24 : Colors.black26),

                const SizedBox(height: 20),

                _buildTicketRow("DATE", "${order.date.day}/${order.date.month}/${order.date.year}", textColor, subTextColor),
                const SizedBox(height: 5),
                _buildTicketRow("HEURE", "${order.date.hour}:${order.date.minute.toString().padLeft(2, '0')}", textColor, subTextColor),
                const SizedBox(height: 5),
                _buildTicketRow("COMMANDE", "#${order.id.substring(0, 6).toUpperCase()}", textColor, subTextColor),

                const SizedBox(height: 20),
                _buildDashedLine(isDark ? Colors.white24 : Colors.black26),
                const SizedBox(height: 20),

                ...order.items.map((item) {
                  final String details = item['details'] ?? "";
                  final bool isMenu = item['name'].toString().startsWith("Menu");

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${item['quantity']}x ",
                              style: GoogleFonts.courierPrime(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)
                            ),
                            Expanded(
                              child: Text(
                                item['name'].toUpperCase(),
                                style: GoogleFonts.courierPrime(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                              ),
                            ),
                            Text(
                              "${(item['price'] * item['quantity']).toStringAsFixed(2)}",
                              style: GoogleFonts.courierPrime(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                            ),
                          ],
                        ),
                        if (isMenu && details.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 25, top: 2),
                            child: Text(
                              details.replaceAll("•", "-"),
                              style: GoogleFonts.courierPrime(fontSize: 10, color: subTextColor),
                            ),
                          )
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 20),
                _buildDashedLine(isDark ? Colors.white24 : Colors.black26),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("TOTAL", style: GoogleFonts.courierPrime(fontSize: 22, fontWeight: FontWeight.w900, color: textColor)),
                    Text("${order.total.toStringAsFixed(2)} €", style: GoogleFonts.courierPrime(fontSize: 22, fontWeight: FontWeight.w900, color: textColor)),
                  ],
                ),

                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("TVA (10%)", style: GoogleFonts.courierPrime(fontSize: 12, color: subTextColor)),
                    Text("${(order.total * 0.1).toStringAsFixed(2)} €", style: GoogleFonts.courierPrime(fontSize: 12, color: subTextColor)),
                  ],
                ),

                const SizedBox(height: 40),

                Image.network(
                  "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/QR_code_for_mobile_English_Wikipedia.svg/1200px-QR_code_for_mobile_English_Wikipedia.svg.png",
                  height: 60,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                const SizedBox(height: 15),
                Text(
                  "*** MERCI DE VOTRE COMMANDE ***",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.courierPrime(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketRow(String label, String value, Color textColor, Color subTextColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.courierPrime(fontSize: 12, color: subTextColor)),
        Text(value, style: GoogleFonts.courierPrime(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
      ],
    );
  }

  Widget _buildDashedLine(Color color) {
    return Row(
      children: List.generate(40, (index) => Expanded(
        child: Container(
          color: index % 2 == 0 ? color : Colors.transparent,
          height: 1.5,
        ),
      )),
    );
  }
}