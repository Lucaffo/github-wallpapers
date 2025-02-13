import 'package:image/image.dart';
import 'package:http/http.dart' as http;
import 'package:wallpaper/wallpaper.dart';
import 'package:wallpaper_generator/src/color_from_string.dart';
import 'package:paths_collection/src/path_collection.dart';
import 'package:paths_collection/src/path_url.dart';

class WallpaperGenerator {

  static final PathCollection logos = PathCollection("logos", "https://lucaffo.github.io/github-wallpapers/static/logos/paths.json");
  static final PathCollection octocats = PathCollection("octocats", "https://lucaffo.github.io/github-wallpapers/static/octocats/paths.json");
  static final PathCollection backgrounds = PathCollection("backgrounds", "https://lucaffo.github.io/github-wallpapers/static/backgrounds/paths.json");

  static Future<Image?> generateWallpaper(Wallpaper wallpaper) async {

    // Make sure to load all the urls
    await logos.readAllUrls();
    await octocats.readAllUrls(); 
    await backgrounds.readAllUrls();

    // Generate the image
    int wallpaperWidth = wallpaper.width;
    int wallpaperHeight = wallpaper.height;
    Image finalImage = Image(width: wallpaperWidth, height: wallpaperHeight, numChannels: 4);

    // Evaluate the background
    WallpaperBackground? wallpaperBackground = wallpaper.background;
    if (wallpaperBackground != null) {

      finalImage = fill(finalImage, color: ColorFromString.fromString(wallpaperBackground.color));
      String? src = wallpaperBackground.src;
      String? name = wallpaperBackground.name;

      // Inject the src from name
      if(name != null && name.isNotEmpty) {
        PathUrl? backgroundSrc = backgrounds.search(name);
        if(backgroundSrc != null) {
            src = backgroundSrc.getFullPath();
        }
      }

      // If src is not null, try downloading the image.
      if(src != null && src.isNotEmpty) {
        final http.Response res = await http.get(Uri.parse(src));
        if(res.statusCode == 200) {
          Image? backgroundSrcImage = decodeImage(res.bodyBytes);
          if (backgroundSrcImage != null){
            finalImage = compositeImage(finalImage, backgroundSrcImage);
          }
        }
      }
        
      print("Background image dimensions: ${finalImage.width}x${finalImage.height}");
    }
    
    // Evaluate the logos
    List<WallpaperLogo>? wallpaperLogos = wallpaper.logos;
    print("Number of logos: ${wallpaperLogos?.length}");
    if (wallpaperLogos != null) {
      for (WallpaperLogo wallpaperLogo in wallpaperLogos) {
        print("Processing logo: ${wallpaperLogo.name}");
        String? src;
        String? name = wallpaperLogo.name;
        double size = wallpaperLogo.size;
        WallpaperLogoPosition? position = wallpaperLogo.position;

        // Inject the src from name
        if(name != null && name.isNotEmpty) {
          PathUrl? logoSrc = logos.search(name);
          if(logoSrc != null) {
             src = logoSrc.getFullPath();
          }
        }

        // If src is not null, try downloading the image.
        if(src != null && src.isNotEmpty) {
          final http.Response res = await http.get(Uri.parse(src));
          if(res.statusCode == 200) {

            // Decode the image from the bytes
            Image? logoSrcImage = decodeImage(res.bodyBytes);
            if (logoSrcImage == null) continue;
            
            // Clone the src, and apply a fill multiplication only when alpha is positivie
            Color color = ColorFromString.fromString(wallpaperLogo.color);
            Image blendImage = fill(logoSrcImage.clone(), color: color, mask: logoSrcImage, maskChannel: Channel.alpha);
            
            // Blend the images
            logoSrcImage = compositeImage(logoSrcImage, blendImage, blend: BlendMode.direct, linearBlend: true);
            
            int logoWidth = (logoSrcImage.width * size).toInt();
            int logoHeight = (logoSrcImage.height * size).toInt();

            double logoPosX = position?.x != null ? position!.x : 0.5;
            double logoPosY = position?.y != null ? position!.y : 0.5;
            
            double centerX = ((wallpaperWidth * logoPosX) - logoWidth / 2);
            double centerY = ((wallpaperHeight * logoPosY) - logoHeight / 2);

            finalImage = compositeImage(
              finalImage,
              logoSrcImage, 
              dstX: centerX.toInt(),
              dstY: centerY.toInt(), 
              dstW: logoWidth, 
              dstH: logoHeight);
          }
        }
      }
    }

    return finalImage;
  }
}