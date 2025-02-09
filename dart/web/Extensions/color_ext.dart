import 'dart:math';

extension ColorExtension on String {

  /// Generate a random hex color.
  /// Format is #RRGGBB.
  static String generateHexColor() {
    Random random = Random();
    String color = '#';
    for (int i = 0; i < 6; i++) {
      color += random.nextInt(16).toRadixString(16).padLeft(1, '0').toUpperCase();
    }
    return color;
  }
  
}