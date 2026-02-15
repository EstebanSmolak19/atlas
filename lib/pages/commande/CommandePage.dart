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
    final bool isPremium = user?.premium ?? false;

    final double finalAmount = cartProvider.total;
    final double originalPrice = cartProvider.subTotal + 2.55;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const ProductAppbar(title: "Panier"),
      body: cartItems.isEmpty
          ? const Center(child: Text("Votre panier est vide 🛒"))
          : Column(
              children: [
                // Affichage des points disponibles si des récompenses sont dans le panier
                if (cartProvider.usedRewardPoints > 0)
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [yellowColor.withOpacity(0.2), yellowColor.withOpacity(0.1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: yellowColor, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: yellowColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.stars, color: Colors.black, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Points de fidélité",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${cartProvider.availablePoints} pts disponibles sur ${user?.points ?? 0} pts",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "-${cartProvider.usedRewardPoints} pts",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.red[700],
                          ),
                        ),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: item.isReward
                              ? Border.all(color: yellowColor, width: 2)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: item.isReward
                                            ? yellowColor.withOpacity(0.3)
                                            : yellowColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.asset(
                                          'assets/${item.product.img_url}',
                                          fit: BoxFit.contain,
                                          errorBuilder: (ctx, err, stack) =>
                                              Image.asset('assets/pizza1.png'),
                                        ),
                                      ),
                                    ),
                                    if (item.isReward)
                                      Positioned(
                                        top: -5,
                                        right: -5,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: yellowColor,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: yellowColor.withOpacity(0.5),
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.star,
                                            color: Colors.black,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.product.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          if (item.isReward)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: yellowColor,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                "GRATUIT",
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      if (item.isReward)
                                        Text(
                                          "Récompense • ${item.rewardCost} pts",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )
                                      else
                                        Text(
                                          "${item.product.price}€",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (!item.isReward)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            cartProvider.updateQuantity(item, -1);
                                          },
                                          child: const Icon(Icons.remove, size: 18),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Text(
                                            "${item.quantity}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            cartProvider.updateQuantity(item, 1);
                                          },
                                          child: const Icon(Icons.add, size: 18),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.red),
                                    onPressed: () {
                                      cartProvider.removeItem(item);
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Sous-total",
                              style: TextStyle(color: Colors.grey, fontSize: 16)),
                          Text("${cartProvider.subTotal.toStringAsFixed(2)}€",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Points gagnés",
                              style: TextStyle(color: Colors.grey, fontSize: 16)),
                          Text("${cartProvider.points}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Frais de livraison",
                              style: TextStyle(color: Colors.grey, fontSize: 16)),
                          cartProvider.deliveryFee == 0
                              ? const Text("Offerts",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.green))
                              : Text(
                                  "${cartProvider.deliveryFee.toStringAsFixed(2)}€",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("Total",
                              style: TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 20)),
                          isPremium
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${originalPrice.toStringAsFixed(2)}€",
                                      style: const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      "${finalAmount.toStringAsFixed(2)}€",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 20,
                                          color: Color.fromARGB(255, 105, 180, 115)),
                                    ),
                                  ],
                                )
                              : Text(
                                  "${finalAmount.toStringAsFixed(2)} €",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900, fontSize: 20),
                                ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: cartItems.isEmpty
                              ? null
                              : () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.payment,
                                    arguments: {
                                      'total': finalAmount,
                                      'points': cartProvider.points,
                                      'pointsToDeduct': cartProvider.getPointsToDeduct(),
                                    },
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: yellowColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            "Payer la commande",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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