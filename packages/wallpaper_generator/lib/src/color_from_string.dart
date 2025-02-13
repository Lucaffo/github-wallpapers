import 'package:image/image.dart';

extension ColorFromString on Color {

  static Color fromString(String? colorStr) {
    // Default color if not provided
    if(colorStr == null) return rgbaToColorUint8(0, 0, 0, 1.0);

    // Color from rgba
    if (colorStr.startsWith("rgba")) {
      List<String> rgbaList = colorStr.substring(5, colorStr.length - 1).split(",");
      int r = num.parse(rgbaList[0].trim()).toInt();
      int g = num.parse(rgbaList[1].trim()).toInt();
      int b = num.parse(rgbaList[2].trim()).toInt();
      double a = num.parse(rgbaList[3].trim()).toDouble();
      return rgbaToColorUint8(r, g, b, a);
    }

    // Default fallback to black
    return rgbaToColorUint8(0, 0, 0, 1.0); 
  }

  // Convert a rgba color to ColorUint8
  static ColorUint8 rgbaToColorUint8(int r, int g, int b, double a) {
    int alpha = (a * 255).round().clamp(0, 255); // Convert alpha to 0-255
    return ColorUint8.rgba(r, g, b, alpha);
  }
}
