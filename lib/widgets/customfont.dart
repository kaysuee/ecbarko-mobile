import 'package:flutter/material.dart';

class CustomFont extends StatelessWidget {
  const CustomFont({
    super.key,
    required this.text,
    required this.fontSize,
    required this.color,
    this.fontFamily = 'Poppins',
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.left,
    this.letterSpacing = 0,
    this.fontStyle = FontStyle.normal,
    this.decoration = TextDecoration.none,
    this.decorationColor,
  });

  final String text;
  final double fontSize, letterSpacing;
  final Color color;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final String fontFamily;
  final FontStyle fontStyle;
  final TextDecoration decoration;
  final Color? decorationColor;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        decoration: decoration,
        decorationColor: decorationColor,
      ),
    );
  }
}
