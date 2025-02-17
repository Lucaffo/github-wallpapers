import 'package:image/image.dart';
import 'package:wallpaper/wallpaper.dart';
import 'package:wallpaper_generator/src/color_from_string.dart';
import 'package:paths_collection/src/path_collection.dart';
import 'package:paths_collection/src/path_url.dart';
import 'dart:html';
import 'dart:typed_data';

import 'package:worker_database/worker_database.dart';

class WallpaperGenerator {

  static final PathCollection logos = PathCollection("https://lucaffo.github.io/github-wallpapers/static/logos/paths.json");
  static final PathCollection octocats = PathCollection("https://lucaffo.github.io/github-wallpapers/static/octocats/paths.json");
  static final PathCollection backgrounds = PathCollection("https://lucaffo.github.io/github-wallpapers/static/backgrounds/paths.json");

  static Future<Uint8List?> generateWallpaper(Wallpaper wallpaper) async {

    // Fetch the imageDB for image caching
    WorkerDatabase imageDB = WorkerDatabase<ByteBuffer, String>("ImagesDB", "ImageStore");

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

      Color backgroundColor = ColorFromString.fromString(wallpaperBackground.color);
      finalImage = fill(finalImage, color: backgroundColor);
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
        
        // Try to hit the image from cache or get via http
        ByteBuffer? resCache = await imageDB.tryFetch(src);
        if(resCache == null){
          final HttpRequest res = await HttpRequest.request(src, responseType: 'arraybuffer');
          if(res.status == 200){
            resCache = res.response as ByteBuffer;
            imageDB.tryPut(src, resCache);
          }
        }

        // Convert the response into array of bytes
        if(resCache != null){
          Uint8List imageBytes = Uint8List.view(resCache);
          Image? backgroundSrcImage = decodeImage(imageBytes);
          if (backgroundSrcImage != null){
            finalImage.clear(ColorFromString.fromString(null)); // Apply default background color
            backgroundSrcImage = scaleRgba(backgroundSrcImage, scale: backgroundColor);
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
        String? type = wallpaperLogo.type;
        String? name = wallpaperLogo.name;
        double size = wallpaperLogo.size;
        WallpaperLogoPosition? position = wallpaperLogo.position;

        // Inject the src from name
        if(name != null && name.isNotEmpty && type != null && type.isNotEmpty) {
          switch(type)
          {
            case "octocat":
              PathUrl? octocatSrc = octocats.search(name);
              if(octocatSrc != null) {
                src = octocatSrc.getFullPath();
              }
              break;
            case "logo":
              PathUrl? logoSrc = logos.search(name);
              if(logoSrc != null) {
                src = logoSrc.getFullPath();
              }
              break;
          }
        }

        // If src is not null, try downloading the image.
        if(src != null && src.isNotEmpty) {

          // Try to hit the image from cache or get via http
          ByteBuffer? resCache = await imageDB.tryFetch(src);
          if(resCache == null) {
            final HttpRequest res = await HttpRequest.request(src, responseType: 'arraybuffer');
            if(res.status == 200) {
              resCache = res.response as ByteBuffer;
              imageDB.tryPut(src, resCache);
            }
          }

          // Convert the response into array of bytes
          if(resCache != null) {

            // Decode the image from the bytes
            Uint8List imageBytes = Uint8List.view(resCache);
            Image? logoSrcImage = decodeImage(imageBytes);
            if (logoSrcImage == null) continue;
            
            // Apply the color by multiplication
            Color color = ColorFromString.fromString(wallpaperLogo.color);
            logoSrcImage = scaleRgba(logoSrcImage, scale: color, mask: logoSrcImage, maskChannel: Channel.alpha);

            // Calculate the final logo position
            int logoWidth = (logoSrcImage.width * size).toInt();
            int logoHeight = (logoSrcImage.height * size).toInt();

            double logoPosX = position?.x != null ? position!.x : 0.5;
            double logoPosY = position?.y != null ? position!.y : 0.5;
            
            double centerX = ((wallpaperWidth * logoPosX) - logoWidth / 2);
            double centerY = ((wallpaperHeight * logoPosY) - logoHeight / 2);

            // Apply the logo into the final image
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

    return finalImage.getBytes();
  }
}