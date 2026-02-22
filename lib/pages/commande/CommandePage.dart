import 'package:atlas/models/AppRoutes.dart';
import 'package:atlas/providers/CommandeProvider.dart';
import 'package:atlas/providers/UserProvider.dart';
import 'package:atlas/widgets/appbar/ProductAppbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommandePage extends StatefulWidget {
  const CommandePage({super.key});

  @override
  State<CommandePage> createState() => _CommandePageState();
}

class _CommandePageState extends State<CommandePage> {
  final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    Provider.of<Commandeprovider>(context, listen: false).updateUser(user);
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<Commandeprovider>();
    final cartItems = cartProvider.items;
    final user = context.watch<UserProvider>().user;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final Color cardBg = Theme.of(context).cardColor;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.white70 : Colors.grey[600]!;

    final double finalAmount = cartProvider.total;
    final double originalPrice = cartProvider.subTotal + 2.55;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: const ProductAppbar(title: "Panier"),
      body: cartItems.isEmpty
          ? Center(child: Text("Votre panier est vide 🛒", style: TextStyle(color: textColor, fontSize: 16)))
          : Column(
              children: [
                if (cartProvider.usedRewardPoints > 0)
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                          ? [yellowColor.withOpacity(0.15), yellowColor.withOpacity(0.05)]
                          : [yellowColor.withOpacity(0.2), yellowColor.withOpacity(0.1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: yellowColor.withOpacity(0.5), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: yellowColor, shape: BoxShape.circle),
                          child: const Icon(Icons.stars, color: Colors.black, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Points de fidélité", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                              const SizedBox(height: 2),
                              Text("${cartProvider.availablePoints} pts disponibles sur ${user?.points ?? 0} pts", style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.grey[700])),
                            ],
                          ),
                        ),
                        Text("-${cartProvider.usedRewardPoints} pts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? yellowColor : Colors.red[700])),
                      ],
                    ),
                  ),

                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: cartItems.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: item.isReward ? Border.all(color: yellowColor, width: 2) : Border.all(color: isDark ? Colors.white10 : Colors.transparent),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 10, offset: const Offset(0, 5))],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(color: yellowColor.withOpacity(0.15), borderRadius: BorderRadius.circular(15)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset('${item.product.img_url}', fit: BoxFit.contain, errorBuilder: (c,e,s) => const Icon(Icons.fastfood)),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${item.product.name}${item.isMenu ? ' (MENU)' : ''}",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                                  ),
                                  const SizedBox(height: 5),
                                  Text("${item.unitPrice.toStringAsFixed(2)}€", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textColor)),
                                ],
                              ),
                            ),
                            if (!item.isReward)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  children: [
                                    GestureDetector(onTap: () => cartProvider.updateQuantity(item, -1), child: Icon(Icons.remove, size: 18, color: textColor)),
                                    Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text("${item.quantity}", style: TextStyle(fontWeight: FontWeight.bold, color: textColor))),
                                    GestureDetector(onTap: () => cartProvider.updateQuantity(item, 1), child: Icon(Icons.add, size: 18, color: textColor)),
                                  ],
                                ),
                              )
                            else
                              IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => cartProvider.removeItem(item)),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.1), blurRadius: 20, offset: const Offset(0, -5))]
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Sous-total", style: TextStyle(color: subTextColor, fontSize: 16)),
                          Text("${cartProvider.subTotal.toStringAsFixed(2)}€", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Points à gagner", style: TextStyle(color: subTextColor, fontSize: 16)),
                          Text("+${cartProvider.points} pts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: yellowColor)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Frais de livraison", style: TextStyle(color: subTextColor, fontSize: 16)),
                          cartProvider.deliveryFee == 0
                              ? const Text("Offerts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green))
                              : Text("${cartProvider.deliveryFee.toStringAsFixed(2)}€", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                        ],
                      ),
                      Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Divider(color: isDark ? Colors.white10 : Colors.grey[200])),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: textColor)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (cartProvider.hasEffectiveDiscount)
                                Text("${originalPrice.toStringAsFixed(2)}€", style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 14)),
                              Text(
                                "${finalAmount.toStringAsFixed(2)}€",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                  color: cartProvider.hasEffectiveDiscount ? Colors.green : textColor
                                )
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: cartItems.isEmpty ? null : () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.payment,
                              arguments: {
                                'total': finalAmount,
                                'points': cartProvider.points,
                                'pointsToDeduct': cartProvider.getPointsToDeduct()
                              }
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? yellowColor : Colors.black,
                            foregroundColor: isDark ? Colors.black : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                          ),
                          child: const Text("Payer la commande", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}