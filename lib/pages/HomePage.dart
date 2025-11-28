import 'package:atlas/models/UserModel.dart';
import 'package:atlas/services/UserService.dart';
import 'package:atlas/widgets/customAppbar.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UserService _userService = UserService();
  final Color yellowColor = const Color.fromARGB(255, 242, 202, 80);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(),
      body: FutureBuilder<UserModel?>(
        future: _userService.getCurrentUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Oups, une erreur est survenue"));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Utilisateur introuvable"));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Découverte',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Card(
                        color: yellowColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 27, top: 20, bottom: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Burgers Express",
                                      style: GoogleFonts.lilitaOne(
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal,
                                        letterSpacing: 2.5,
                                        color: const Color.fromARGB(
                                                255, 51, 41, 38)
                                            .withOpacity(0.6),
                                        height: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    Text(
                                      "-30% ICI",
                                      style: GoogleFonts.titanOne(
                                        fontSize: 35,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.brown[900],
                                        height: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 20),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        "Commander",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 65,
                        top: -80,
                        bottom: -20,
                        width: 530,
                        child: Stack(
                          children: [
                            Transform.translate(
                              offset: const Offset(5, 8),
                              child: ImageFiltered(
                                imageFilter: ui.ImageFilter.blur(
                                    sigmaX: 6.0, sigmaY: 6.0),
                                child: Image.asset(
                                  'assets/burger1.png',
                                  fit: BoxFit.contain,
                                  color: Colors.black.withOpacity(0.4),
                                  colorBlendMode: BlendMode.srcIn,
                                ),
                              ),
                            ),
                            Image.asset(
                              'assets/burger1.png',
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // Dots sous l'affiche
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 25,
                      height: 8,
                      decoration: BoxDecoration(
                        color: yellowColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    const SizedBox(width: 5),

                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                    ),
                    
                    const SizedBox(width: 5),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}