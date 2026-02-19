import 'package:flutter/material.dart';

Widget buildInfoBadge(BuildContext context, IconData icon, String text, Color iconColor) {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        color: iconColor,
        size: 20
      ),
      const SizedBox(width: 6),
      Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: isDark ? Colors.white70 : Colors.grey[700],
        ),
      ),
    ],
  );
}