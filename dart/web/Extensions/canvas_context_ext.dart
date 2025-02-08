import 'dart:html';

extension CanvasRenderingContext2DSetFillStyleAndAlpha on CanvasRenderingContext2D {
  void setFillStyleAndAlpha(String? color) {
    if (color == null || color.isEmpty) {
      globalAlpha = 1.0;
      fillStyle = 'rgba(255, 255, 255, 1)';
      return;
    }

    final rgbaMatch = RegExp(r'rgba\((\d+), (\d+), (\d+), (\d+(\.\d+)?)\)').firstMatch(color);
    if (rgbaMatch != null) {
      final r = int.parse(rgbaMatch.group(1)!);
      final g = int.parse(rgbaMatch.group(2)!);
      final b = int.parse(rgbaMatch.group(3)!);
      final alpha = double.parse(rgbaMatch.group(4)!);

      globalAlpha = alpha;
      fillStyle = 'rgba($r, $g, $b, $alpha)';
      return;
    } else {
      final rgbMatch = RegExp(r'rgb\((\d+), (\d+), (\d+)\)').firstMatch(color);
      if (rgbMatch != null) {
        final r = int.parse(rgbMatch.group(1)!);
        final g = int.parse(rgbMatch.group(2)!);
        final b = int.parse(rgbMatch.group(3)!);

        globalAlpha = 1.0;
        fillStyle = 'rgba($r, $g, $b, 1)';
        return;
      } else {
        final rgbaMatchNoAlpha = RegExp(r'rgb\((\d+), (\d+), (\d+), (\d+(\.\d+)?)\)').firstMatch(color);
        if (rgbaMatchNoAlpha != null) {
          final r = int.parse(rgbaMatchNoAlpha.group(1)!);
          final g = int.parse(rgbaMatchNoAlpha.group(2)!);
          final b = int.parse(rgbaMatchNoAlpha.group(3)!);
          final alpha = double.parse(rgbaMatchNoAlpha.group(4)!);

          globalAlpha = alpha;
          fillStyle = 'rgba($r, $g, $b, $alpha)';
          return;
        }
      }
    }

    globalAlpha = 1.0;
    fillStyle = 'rgba(255, 255, 255, 1)';
  }
}
