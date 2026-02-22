import 'package:atlas/models/ProductModel.dart';
import 'package:atlas/pages/product/ReviewPage.dart';
import 'package:atlas/providers/CommandeProvider.dart';
import 'package:atlas/services/UserService.dart';
import 'package:atlas/widgets/QtyBtn.dart';
import 'package:atlas/widgets/appbar/detailAppBar.dart';
import 'package:atlas/widgets/infoBadge.dart';
import 'package:atlas/widgets/login/Toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DetailPage extends StatefulWidget {
  final bool isMenu;

  const DetailPage({
    super.key,
    this.isMenu = false,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int quantity = 1;
  late bool isMenu;
  final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    isMenu = widget.isMenu;
  }

  @override
  Widget build(BuildContext context) {
    final productArg = ModalRoute.of(context)!.settings.arguments as ProductModel;
    final commandeProvider = context.watch<Commandeprovider>();

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBg = Theme.of(context).cardColor;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.white70 : Colors.grey[600]!;
    final Color toggleBg = isDark ? Colors.white10 : const Color(0xFFF5F5F5);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('products').doc(productArg.id).snapshots(),
      builder: (context, snapshot) {

        ProductModel product = productArg;
        if (snapshot.hasData && snapshot.data!.exists) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          data['id'] = snapshot.data!.id;
          product = ProductModel.fromMap(data);
        }

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
                  child: Hero(
                    tag: productArg.name,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.translate(
                          offset: const Offset(10, 15),
                          child: ImageFiltered(
                            imageFilter: ui.ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.4),
                                BlendMode.srcIn
                              ),
                              child: Image.asset(
                                '${product.img_url}',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const SizedBox(),
                              ),
                            ),
                          ),
                        ),
                        Image.asset(
                          '${product.img_url}',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood, size: 100),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black54 : Colors.black12,
                        blurRadius: 20,
                        offset: const Offset(0, -5)
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildNationalityBadge(product.nationality, isDark),

                              const SizedBox(height: 10),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      product.name,
                                      style: GoogleFonts.lilitaOne(
                                        fontSize: 28,
                                        color: textColor,
                                        height: 1.1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "${(isMenu ? product.price + 3.99 : product.price).toStringAsFixed(2)}€",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? yellowColor : const Color(0xFFD4AF37),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              Row(
                                children: [
                                  buildInfoBadge(context, Icons.star, product.average.toStringAsFixed(1), Colors.orange),
                                  const SizedBox(width: 20),
                                  buildInfoBadge(context, Icons.local_fire_department, "${product.calorie.toString()} kcal", Colors.redAccent),
                                  const SizedBox(width: 20),
                                  buildInfoBadge(context, Icons.access_time_filled, "${product.time.toString()} min", Colors.blueGrey),
                                ],
                              ),

                              const SizedBox(height: 15),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () => _showReviewModal(context, product, isDark),
                                    child: Row(
                                      children: [
                                        Icon(Icons.rate_review_outlined, size: 18, color: subTextColor),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Donner mon avis (${product.rating_count})",
                                          style: TextStyle(
                                            color: subTextColor,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const ReviewsPage(),
                                          settings: RouteSettings(arguments: product),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Voir les avis",
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 25),

                              // TOGGLE MENU / SIMPLE
                              Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: toggleBg,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Stack(
                                  children: [
                                    AnimatedAlign(
                                      alignment: isMenu ? Alignment.centerRight : Alignment.centerLeft,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                      child: FractionallySizedBox(
                                        widthFactor: 0.5,
                                        child: Container(
                                          margin: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: isDark ? Colors.grey[800] : Colors.white,
                                            borderRadius: BorderRadius.circular(25),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.1),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            behavior: HitTestBehavior.translucent,
                                            onTap: () => setState(() => isMenu = false),
                                            child: Center(
                                              child: Text(
                                                "Choix simple",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: !isMenu ? textColor : Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: GestureDetector(
                                            behavior: HitTestBehavior.translucent,
                                            onTap: () => setState(() => isMenu = true),
                                            child: Center(
                                              child: Text(
                                                "Menu (+3.99€)",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: isMenu ? textColor : Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 25),

                              Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                              const SizedBox(height: 10),
                              Text(
                                product.description,
                                style: TextStyle(fontSize: 14, color: subTextColor, height: 1.5),
                              ),

                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: toggleBg,
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
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor),
                                  ),
                                ),
                                buildQtyBtn(Icons.add, () => setState(() => quantity++)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Ajout au panier avec le flag isMenu
                                commandeProvider.addItem(product, quantity, isMenu: isMenu);
                                Toast.show(context, "${quantity} ${product.name} ${isMenu ? '(Menu)' : ''} ajouté au panier !");
                                Navigator.pop(context); // Retour à la carte
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? yellowColor : Colors.black,
                                foregroundColor: isDark ? Colors.black : Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                elevation: 5,
                              ),
                              child: Text(
                                isMenu ? "Ajouter le Menu" : "Ajouter au panier",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildNationalityBadge(String nationality, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white12 : Colors.black,
        borderRadius: BorderRadius.circular(20)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.public, color: yellowColor, size: 14),
          const SizedBox(width: 6),
          Text(
            nationality.toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)
          ),
        ],
      ),
    );
  }

  void _showReviewModal(BuildContext context, ProductModel product, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        int selectedStars = 5;
        final TextEditingController commentController = TextEditingController();
        bool isSending = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: EdgeInsets.only(
                top: 25,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50, height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10)
                      )
                    )
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Noter ${product.name}",
                    style: GoogleFonts.lilitaOne(fontSize: 24, color: isDark ? Colors.white : Colors.black)
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () {
                          setModalState(() {
                            selectedStars = index + 1;
                          });
                        },
                        icon: Icon(
                          index < selectedStars ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: Colors.orange,
                          size: 40,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: commentController,
                    maxLines: 4,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: "Racontez-nous votre expérience culinaire...",
                      hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                      filled: true,
                      fillColor: isDark ? Colors.white10 : const Color(0xFFF9F9F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSending ? null : () async {
                        setModalState(() => isSending = true);
                        try {
                          await _userService.submitReview(product.id, selectedStars, commentController.text);
                          if (context.mounted) {
                            Navigator.pop(context);
                            Toast.show(context, "Merci pour votre avis ! ⭐");
                          }
                        } catch (e) {
                          if (context.mounted) {
                            Toast.show(context, e.toString().replaceAll("Exception: ", ""));
                            setModalState(() => isSending = false);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? yellowColor : Colors.black,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: isSending
                        ? CircularProgressIndicator(color: isDark ? Colors.black : Colors.white, strokeWidth: 2)
                        : const Text("Envoyer mon avis", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}