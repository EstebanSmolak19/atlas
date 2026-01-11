import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: Colors.black),
      ),
    );
  }