import 'dart:html';
import 'Images/image_urls.dart';
import 'Drawer/wallpaper.dart';

const String canvasId = "#output";

ImageUrls logos = ImageUrls("logos", "https://lucaffo.github.io/github-wallpapers/static/logos/paths.json");
ImageUrls octocats = ImageUrls("octocats", "https://lucaffo.github.io/github-wallpapers/static/octocats/paths.json");

void main() async
{
    await logos.readAllUrls();
    await octocats.readAllUrls();
    querySelector("#generate-1920x1080")?.onClick.listen((_) => generateWallpaper(1920, 1080, 0.5));
    querySelector("#generate-3440x1440")?.onClick.listen((_) => generateWallpaper(3440, 1440, 0.35));
}

Future<void> generateWallpaper(int width, int height, double logoSize) async 
{
  CanvasElement canvas = querySelector(canvasId) as CanvasElement;
  CanvasRenderingContext2D ctx = canvas.context2D;
  Wallpaper wTest = Wallpaper("https://lucaffo.github.io/github-wallpapers/static/configurations/wallpaper_01.json");
  wTest.draw(ctx);
}
