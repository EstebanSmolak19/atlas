import 'package:flutter/material.dart';

class TitleSection extends StatelessWidget {
  final String title;
  final double? size;
  const TitleSection({
    super.key,
    required this.title,
    this.size
    });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: size ?? 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
      ]
    );
  }
}