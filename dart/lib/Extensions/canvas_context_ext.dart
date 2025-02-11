import 'dart:html';

bool isValidHex(String hex) {
  return RegExp(r'^#([A-Fa-f0-9]{3}|[A-Fa-f0-9]{4}|[A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})$')
      .hasMatch(hex);
}

List<String> getChunks(String str, int chunkSize) {
  List<String> chunks = [];
  for (int i = 0; i < str.length; i += chunkSize) {
    chunks.add(str.substring(i, i + chunkSize));
  }
  return chunks;
}

int convertHexUnitTo256(String hexStr) {
  return int.parse(hexStr.length == 1 ? hexStr + hexStr : hexStr, radix: 16);
}

double getAlphaFloat(int? hexAlpha, double? alpha) {
  if (hexAlpha != null) return hexAlpha / 255.0;
  if (alpha != null && alpha >= 0 && alpha <= 1) return alpha;
  return 1.0;
}

String hexToRGBA(String hex, [double? alpha]) {
  if (!isValidHex(hex)) throw ArgumentError("Invalid HEX color: $hex");
  String hexBody = hex.substring(1);
  int chunkSize = (hexBody.length == 3 || hexBody.length == 4) ? 1 : 2;
  List<String> hexArr = getChunks(hexBody, chunkSize);
  int r = convertHexUnitTo256(hexArr[0]);
  int g = convertHexUnitTo256(hexArr[1]);
  int b = convertHexUnitTo256(hexArr[2]);
  int? a;
  if (hexArr.length == 4) a = convertHexUnitTo256(hexArr[3]);
  double aFloat = getAlphaFloat(a, alpha);
  return 'rgba($r, $g, $b, $aFloat)';
}

extension CanvasRenderingContext2DSetFillStyleAndAlpha on CanvasRenderingContext2D {
  void setFillStyleAndAlpha(String? color) {
    if (color == null || color.isEmpty) {
      globalAlpha = 1.0;
      fillStyle = 'rgba(255, 255, 255, 1)';
      return;
    }
    final rgbaMatch = RegExp(
            r'rgba\(\s*(\d+),\s*(\d+),\s*(\d+),\s*(\d+(\.\d+)?)\s*\)')
        .firstMatch(color);
    if (rgbaMatch != null) {
      int r = int.parse(rgbaMatch.group(1)!);
      int g = int.parse(rgbaMatch.group(2)!);
      int b = int.parse(rgbaMatch.group(3)!);
      double a = double.parse(rgbaMatch.group(4)!);
      globalAlpha = a;
      fillStyle = 'rgba($r, $g, $b, $a)';
      return;
    }
    final rgbMatch =
        RegExp(r'rgb\(\s*(\d+),\s*(\d+),\s*(\d+)\s*\)').firstMatch(color);
    if (rgbMatch != null) {
      int r = int.parse(rgbMatch.group(1)!);
      int g = int.parse(rgbMatch.group(2)!);
      int b = int.parse(rgbMatch.group(3)!);
      globalAlpha = 1.0;
      fillStyle = 'rgba($r, $g, $b, 1)';
      return;
    }
    if (color.startsWith('#')) {
      try {
        String rgbaString = hexToRGBA(color);
        List<String> parts =
            rgbaString.substring(5, rgbaString.length - 1).split(',');
        double a = double.parse(parts[3].trim());
        globalAlpha = a;
        fillStyle = rgbaString;
        return;
      } catch (e) {}
    }
    globalAlpha = 1.0;
    fillStyle = 'rgba(255, 255, 255, 1)';
  }
}
