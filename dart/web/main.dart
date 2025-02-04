import 'dart:html';
import 'Drawer/wallpaper.dart';

const String canvasId = "#output";

void main() async
{
    querySelector("#generate-1920x1080")?.onClick.listen((_) => generateWallpaper(1));
    querySelector("#generate-3440x1440")?.onClick.listen((_) => generateWallpaper(2));
}

Future<void> generateWallpaper(int index) async 
{
  CanvasElement canvas = querySelector(canvasId) as CanvasElement;
  CanvasRenderingContext2D ctx = canvas.context2D;
  Wallpaper("https://lucaffo.github.io/github-wallpapers/static/wallpapers/wallpaper_${index.toString().padLeft(2, '0')}.json").draw(ctx);
}
