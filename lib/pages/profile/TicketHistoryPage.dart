import 'package:atlas/models/HistoryModel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TicketHistoryPage extends StatelessWidget {
  final HistoryModel order;

  const TicketHistoryPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
            decoration: BoxDecoration(
              color: const Color(0xFFFDFDFD),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 10))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.restaurant, size: 40, color: Colors.black),
                const SizedBox(height: 10),
                Text("ATLAS FOOD", style: GoogleFonts.courierPrime(fontSize: 24, fontWeight: FontWeight.bold)),
                Text("21 Boulevard du NullPointer", style: GoogleFonts.courierPrime(fontSize: 12, color: Colors.grey[700])),
                Text("Tel: 01 00 00 11 21", style: GoogleFonts.courierPrime(fontSize: 12, color: Colors.grey[700])),
                
                const SizedBox(height: 30),
                
                _buildDashedLine(),
                
                const SizedBox(height: 20),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("DATE", style: GoogleFonts.courierPrime(fontSize: 12, color: Colors.grey[600])),
                    Text("${order.date.day}/${order.date.month}/${order.date.year}", style: GoogleFonts.courierPrime(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("HEURE", style: GoogleFonts.courierPrime(fontSize: 12, color: Colors.grey[600])),
                    Text("${order.date.hour}:${order.date.minute.toString().padLeft(2, '0')}", style: GoogleFonts.courierPrime(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("COMMANDE", style: GoogleFonts.courierPrime(fontSize: 12, color: Colors.grey[600])),
                    Text("#${order.id.substring(0, 6).toUpperCase()}", style: GoogleFonts.courierPrime(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                
                const SizedBox(height: 20),
                _buildDashedLine(),
                const SizedBox(height: 20),
                
                // ITEMS
                ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${item['quantity']}x ", style: GoogleFonts.courierPrime(fontSize: 14, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          item['name'].toUpperCase(),
                          style: GoogleFonts.courierPrime(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        "${(item['price'] * item['quantity']).toStringAsFixed(2)}",
                        style: GoogleFonts.courierPrime(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )),
                
                const SizedBox(height: 20),
                _buildDashedLine(),
                const SizedBox(height: 20),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("TOTAL", style: GoogleFonts.courierPrime(fontSize: 22, fontWeight: FontWeight.w900)),
                    Text("${order.total.toStringAsFixed(2)} €", style: GoogleFonts.courierPrime(fontSize: 22, fontWeight: FontWeight.w900)),
                  ],
                ),
                
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("TVA (10%)", style: GoogleFonts.courierPrime(fontSize: 12, color: Colors.grey[600])),
                    Text("${(order.total * 0.1).toStringAsFixed(2)} €", style: GoogleFonts.courierPrime(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                Image.network(
                  "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/QR_code_for_mobile_English_Wikipedia.svg/1200px-QR_code_for_mobile_English_Wikipedia.svg.png",
                  height: 60,
                  color: Colors.black87,
                ),
                const SizedBox(height: 15),
                Text("*** MERCI DE VOTRE COMMANDE ***", style: GoogleFonts.courierPrime(fontSize: 12, fontWeight: FontWeight.bold)),
                
                // Effet de découpe en bas
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashedLine() {
    return Row(
      children: List.generate(40, (index) => Expanded(
        child: Container(
          color: index % 2 == 0 ? Colors.black : Colors.transparent,
          height: 1.5,
        ),
      )),
    );
  }
}