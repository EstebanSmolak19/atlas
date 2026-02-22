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
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Mes Commandes",
          style: GoogleFonts.lilitaOne(color: textColor, fontSize: 24),
        ),
      ),
      body: historyProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text("Aucune commande trouvée."))
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: orders.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsHistoryPage(order: order),
                          ),
                        );
                      },
                      tileColor: isDark ? Colors.white10 : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      leading: const Icon(Icons.receipt_long),
                      title: Text("${order.date.day}/${order.date.month}/${order.date.year}"),
                      subtitle: Text("${order.total.toStringAsFixed(2)}€"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    );
                  },
                ),
    );
  }
}