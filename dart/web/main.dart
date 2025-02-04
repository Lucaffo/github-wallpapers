import 'dart:html';
import 'Images/image_urls.dart';

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

Future<void> generateWallpaper(int width, int height, double logoSize) async {
  // Prendi il canvas presente sulla pagina
  CanvasElement canvas = querySelector(canvasId) as CanvasElement;
  CanvasRenderingContext2D ctx = canvas.context2D;

  // Resize della canvas
  canvas.width = width;
  canvas.height = height;

  // Puliamo il canvas
  ctx.fillStyle = "black";
  ctx.fillRect(0, 0, canvas.width!, canvas.height!);

  // Creiamo un'immagine dall'avatar
  ImageElement logo = ImageElement();
  try
  {
      logo.src = logos.getRandomUrl()?.getFullPath();
  } 
  on Exception catch(e)
  {
      print(e);
  }

  await logo.onLoad.first; // Aspettiamo che l'immagine si carichi

  // Calcoliamo la posizione centrale
  int logoWidth = (logo.width! * logoSize).toInt();
  int logoHeight = (logo.height! * logoSize).toInt();
  int centerX = (canvas.width! - logoWidth) ~/ 2;
  int centerY = (canvas.height! - logoHeight) ~/ 2;

  // Aggiungi logo al centro scalato
  ctx.drawImageScaled(logo, centerX, centerY, logoWidth, logoHeight);
}
