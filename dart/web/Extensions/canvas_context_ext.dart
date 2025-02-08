import 'dart:html';

extension CanvasRenderingContext2DSetFillStyleAndAlpha on CanvasRenderingContext2D {
  void setFillStyleAndAlpha(String? color) {
    if (color == null || color.isEmpty) return;

    // Se il colore è in formato rgba(r, g, b, a) 
    final rgbaMatch = RegExp(r'rgba\((\d+), (\d+), (\d+), (\d+(\.\d+)?)\)').firstMatch(color);
    if (rgbaMatch != null) {
      // Otteniamo i componenti RGBA
      final r = int.parse(rgbaMatch.group(1)!);
      final g = int.parse(rgbaMatch.group(2)!);
      final b = int.parse(rgbaMatch.group(3)!);
      final alpha = double.parse(rgbaMatch.group(4)!);

      // Impostiamo globalAlpha e fillStyle (con alpha incluso)
      globalAlpha = alpha;
      fillStyle = 'rgba($r, $g, $b, $alpha)';
    }
    // Se il colore è in formato rgb(r, g, b) senza alpha
    else {
      final rgbMatch = RegExp(r'rgb\((\d+), (\d+), (\d+)\)').firstMatch(color);
      if (rgbMatch != null) {
        // Otteniamo i componenti RGB
        final r = int.parse(rgbMatch.group(1)!);
        final g = int.parse(rgbMatch.group(2)!);
        final b = int.parse(rgbMatch.group(3)!);

        // Impostiamo alpha a 1.0 per rgb (opacità piena)
        globalAlpha = 1.0;
        fillStyle = 'rgba($r, $g, $b, 1)';
      }
      // Se il colore è in formato rgb(r, g, b, a)
      else {
        final rgbaMatchNoAlpha = RegExp(r'rgb\((\d+), (\d+), (\d+), (\d+(\.\d+)?)\)').firstMatch(color);
        if (rgbaMatchNoAlpha != null) {
          // Otteniamo i componenti RGB e l'alpha
          final r = int.parse(rgbaMatchNoAlpha.group(1)!);
          final g = int.parse(rgbaMatchNoAlpha.group(2)!);
          final b = int.parse(rgbaMatchNoAlpha.group(3)!);
          final alpha = double.parse(rgbaMatchNoAlpha.group(4)!);

          // Impostiamo globalAlpha e fillStyle (con alpha incluso)
          globalAlpha = alpha;
          fillStyle = 'rgba($r, $g, $b, $alpha)';
        }
      }
    }
  }
}
