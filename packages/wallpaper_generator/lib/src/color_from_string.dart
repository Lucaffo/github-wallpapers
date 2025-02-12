import 'package:image/image.dart';

extension ColorFromString on Color {
  static Color fromString(String? colorStr) {
    if(colorStr == null) return ColorInt8.rgba(0, 0, 0, 1);

    RegExp hexColorRegex = RegExp(r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');

    if (colorStr.startsWith("rgba")) {
      List<String> rgbaList = colorStr.substring(5, colorStr.length - 1).split(",");
      int r = int.parse(rgbaList[0].trim());
      int g = int.parse(rgbaList[1].trim());
      int b = int.parse(rgbaList[2].trim());
      int a = (double.parse(rgbaList[3].trim()) * 255).toInt();
      return ColorInt8.rgba(r, g, b, a);
    } else if (colorStr.startsWith("rgb")) {
      List<int> rgbList = colorStr
          .substring(4, colorStr.length - 1)
          .split(",")
          .map((c) => int.parse(c.trim()))
          .toList();
      return ColorInt8.rgb(rgbList[0], rgbList[1], rgbList[2]);
    } else if (hexColorRegex.hasMatch(colorStr)) {
      colorStr = colorStr.replaceAll("#", "");

      if (colorStr.length == 3) {
        colorStr = colorStr.split('').map((char) => char * 2).join();
      }
      
      if (colorStr.length == 6) {
        int colorValue = int.parse(colorStr, radix: 16);
        return ColorInt8.rgb(
          (colorValue >> 16) & 0xFF,
          (colorValue >> 8) & 0xFF,
          colorValue & 0xFF,
        );
      } else if (colorStr.length == 8) {
        int colorValue = int.parse(colorStr, radix: 16);
        return ColorInt8.rgba(
          (colorValue >> 24) & 0xFF,
          (colorValue >> 16) & 0xFF,
          (colorValue >> 8) & 0xFF,
          colorValue & 0xFF,
        );
      }
    } else if (colorStr.isEmpty) {
      throw UnsupportedError("Empty color field found.");
    } else if (colorStr == 'none') {
      return ColorInt8.rgba(0, 0, 0, 0); // Transparent color
    } else {
      throw UnsupportedError("Only hex, rgb, or rgba color formats are supported. String: $colorStr");
    }

    return ColorInt8.rgb(0, 0, 0); // Default fallback to black
  }
}
