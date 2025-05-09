import 'package:flutter/material.dart';

class RateCard extends StatelessWidget {
  final String? imagePath;
  final String label;
  final Color bgColor, textColor;

  const RateCard({super.key, this.imagePath, required this.label, required this.bgColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 214,
      height: 102,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), 
            spreadRadius: 2, 
            blurRadius: 8, 
            offset: const Offset(0, 4), 
          ),
        ],
      ),
      child: Stack(
        children: [
          if (imagePath != null)
            Positioned(right: 0, top: 0, child: Image.asset(imagePath!, width: 100, fit: BoxFit.cover)),
          Text(label, style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}