import 'dart:html';

import 'Drawer/wallpaper_drawer.dart';
import 'Drawer/wallpaper_drawer_factory.dart';

const String canvasId = "#output";

void main() async {
    querySelector("#generate-1920x1080")?.onClick.listen((_) => generateWallpaper(1));
    querySelector("#generate-3440x1440")?.onClick.listen((_) => generateWallpaper(2));
}

Future<void> generateWallpaper(int index) async {
  CanvasElement canvas = querySelector(canvasId) as CanvasElement;
  CanvasRenderingContext2D ctx = canvas.context2D;
  WallpaperDrawer? drawer = await WallpaperDrawerFactory.getWallpaperDrawer(index);
  drawer?.draw(ctx);
}
