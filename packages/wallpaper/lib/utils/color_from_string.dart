import 'package:image/image.dart';

/*
*   Comvert a color from a String.
*
*   Luca Raffo @ 25/02/2025
*/ 
extension ColorFromString on String {

  // Get a color from string
  Color toColor() {
    
    // Color from rgba
    if (startsWith("rgba")) {
      List<String> rgbaList = substring(5, length - 1).split(",");
      int r = num.parse(rgbaList[0].trim()).toInt();
      int g = num.parse(rgbaList[1].trim()).toInt();
      int b = num.parse(rgbaList[2].trim()).toInt();
      double a = num.parse(rgbaList[3].trim()).toDouble();
      return _rgbaToColorUint8(r, g, b, a);
    }

    // Default fallback to black
    return _rgbaToColorUint8(0, 0, 0, 1.0); 
  }

  // Convert a rgba color to ColorUint8
  static ColorUint8 _rgbaToColorUint8(int r, int g, int b, double a) {
    int alpha = (a * 255).round().clamp(0, 255); // Convert alpha to 0-255
    return ColorUint8.rgba(r, g, b, alpha);
  }
}
