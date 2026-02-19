import 'package:atlas/models/ProductModel.dart';
import 'package:atlas/providers/ProductProvider.dart';
import 'package:atlas/services/UserService.dart';
import 'package:atlas/widgets/login/Toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  final UserService _userService = UserService();
  final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as ProductModel;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Avis Clients",
          style: GoogleFonts.lilitaOne(color: textColor, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildHeaderStats(product, isDark, textColor),

          Divider(height: 1, color: isDark ? Colors.white10 : const Color(0xFFEEEEEE)),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .doc(product.id)
                  .collection('reviews')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text("Oups, une erreur est survenue.", style: TextStyle(color: textColor)));
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: isDark ? yellowColor : Colors.black));

                final reviews = snapshot.data!.docs;

                if (reviews.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.comment_outlined, size: 60, color: isDark ? Colors.white10 : Colors.grey[300]),
                        const SizedBox(height: 15),
                        Text(
                          "Aucun avis pour le moment.\nSoyez le premier !",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: isDark ? Colors.white38 : Colors.grey[500], fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
                  itemCount: reviews.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final data = reviews[index].data() as Map<String, dynamic>;
                    return _buildReviewTile(data, isDark, textColor);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showReviewModal(context, product, isDark),
        backgroundColor: isDark ? yellowColor : Colors.black,
        icon: Icon(Icons.edit, color: isDark ? Colors.black : Colors.white),
        label: Text("Écrire un avis", style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeaderStats(ProductModel product, bool isDark, Color textColor) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('products').doc(product.id).snapshots(),
      builder: (context, snapshot) {
        double average = product.average;
        int count = product.rating_count;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          average = (data['average'] ?? 0.0).toDouble();
          count = (data['rating_count'] ?? 0).toInt();
        }

        return Container(
          padding: const EdgeInsets.all(25),
          color: isDark ? Colors.white.withOpacity(0.03) : const Color(0xFFFAFAFA),
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    average.toStringAsFixed(1),
                    style: GoogleFonts.lilitaOne(fontSize: 48, color: textColor, height: 1),
                  ),
                  Row(
                    children: List.generate(5, (i) => Icon(
                      i < average.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: Colors.orange,
                      size: 20,
                    )),
                  ),
                  const SizedBox(height: 5),
                  Text("$count avis", style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(width: 25),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("L'avis des explorateurs", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                    const SizedBox(height: 5),
                    Text(
                      "Découvrez ce que les autres voyageurs pensent de ce plat.",
                      style: TextStyle(color: isDark ? Colors.white38 : Colors.grey[600], fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      }
    );
  }

  Widget _buildReviewTile(Map<String, dynamic> data, bool isDark, Color textColor) {
    final int rating = (data['rating'] ?? 0).toInt();
    final String comment = data['comment'] ?? "";
    final Timestamp? createdAt = data['createdAt'];
    final String userName = data['userName'] ?? "Explorateur Atlas";

    String dateStr = "";
    if (createdAt != null) {
      final date = createdAt.toDate();
      dateStr = "${date.day}/${date.month}/${date.year}";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? yellowColor : Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : "A",
                        style: GoogleFonts.lilitaOne(color: isDark ? Colors.black : yellowColor, fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: textColor)),
                      const SizedBox(height: 2),
                      Row(
                        children: List.generate(5, (i) => Icon(
                          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: Colors.orange,
                          size: 16,
                        )),
                      ),
                    ],
                  ),
                ],
              ),
              Text(dateStr, style: TextStyle(color: isDark ? Colors.white24 : Colors.grey[400], fontSize: 12)),
            ],
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              comment,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? Colors.white70 : Colors.black87
              )
            ),
          ]
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
                      decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                    ),
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
                      fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF9F9F9),
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
                            Provider.of<ProductProvider>(context, listen: false).updateSingleProduct(product.id);
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
                        ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: isDark ? Colors.black : Colors.white, strokeWidth: 2))
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