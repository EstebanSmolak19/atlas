import 'package:atlas/pages/profile/DetailsHistoryPage.dart';
import 'package:atlas/providers/HistoryProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      Provider.of<HistoryProvider>(context, listen: false).fetchUserHistory()
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = context.watch<HistoryProvider>();
    final orders = historyProvider.orders;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final Color cardBg = Theme.of(context).cardColor;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.white38 : Colors.grey[500]!;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? cardBg : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
                ]
              ),
              child: Icon(Icons.arrow_back, color: textColor, size: 20),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          "Mes Commandes",
          style: GoogleFonts.lilitaOne(color: textColor, fontSize: 24),
        ),
      ),
      body: historyProvider.isLoading
          ? Center(child: CircularProgressIndicator(color: isDark ? yellowColor : Colors.black))
          : orders.isEmpty
              ? _buildEmptyState(isDark, textColor)
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: orders.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsHistoryPage(order: order),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isDark ? Colors.white10 : Colors.transparent),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: yellowColor.withOpacity(isDark ? 0.1 : 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.receipt, color: yellowColor, size: 24),
                                ),
                                const SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${order.date.day}/${order.date.month}/${order.date.year}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: textColor
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${order.total.toStringAsFixed(2)}€ • ${order.items.length} articles",
                                      style: TextStyle(color: subTextColor, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.white24 : Colors.grey[400]),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState(bool isDark, Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: yellowColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long, size: 60, color: yellowColor),
          ),
          const SizedBox(height: 20),
          Text(
            "Aucune commande",
            style: GoogleFonts.lilitaOne(fontSize: 22, color: textColor),
          ),
          const SizedBox(height: 10),
          Text(
            "Vos futures aventures culinaires\napparaitront ici.",
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}