import 'package:flutter/material.dart';

class ColorLetterAvatar extends StatelessWidget {
  final String letter;
  final Color color;
  final double size;

  const ColorLetterAvatar({
    super.key,
    required this.letter,
    required this.color,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color,
      child: Text(
        letter.isEmpty ? '?' : letter[0].toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.42,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

Color colorFromHex(String hex) {
  final clean = hex.replaceAll('#', '');
  final argb = int.tryParse(
        clean.length == 6 ? 'FF$clean' : clean,
        radix: 16,
      ) ??
      0xFF9E9E9E;
  return Color(argb);
}

String colorToHex(Color color) {
  final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
  final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
  final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
  return '#${r.toUpperCase()}${g.toUpperCase()}${b.toUpperCase()}';
}
