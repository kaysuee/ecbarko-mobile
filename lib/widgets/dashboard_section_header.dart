import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/customfont.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const SectionHeader({super.key, required this.title, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomFont(text: title, fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
          GestureDetector(
            onTap: onViewAll,
            child: const CustomFont(
              text: 'view all',
              fontSize: 16,
              color: Ec_TEXT_COLOR_GREY,
              fontWeight: FontWeight.normal,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}