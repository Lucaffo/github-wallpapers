import 'package:image/image.dart';
import 'package:wallpaper/wallpaper.dart';
import 'package:wallpaper_generator/src/color_from_string.dart';
import 'package:paths_collection/src/path_collection.dart';
import 'package:paths_collection/src/path_url.dart';
import 'package:wallpaper_generator/src/wallpaper_image_database.dart';
import 'dart:html';
import 'dart:typed_data';

class WallpaperGenerator {

  static final PathCollection logos = PathCollection("https://lucaffo.github.io/github-wallpapers/static/logos/paths.json");
  static final PathCollection octocats = PathCollection("https://lucaffo.github.io/github-wallpapers/static/octocats/paths.json");
  static final PathCollection backgrounds = PathCollection("https://lucaffo.github.io/github-wallpapers/static/backgrounds/paths.json");

  static Future<Uint8List?> generateWallpaper(Wallpaper wallpaper, Function(String) updatingFunction) async {

    // Fetch the imageDB for image caching
    WallpaperImageDatabase imageDatabase = WallpaperImageDatabase("ImagesDB", "ImageStore");

    // Make sure to load all the urls
    updatingFunction("Loading all the paths resources...");
    await logos.readAllUrls();
    await octocats.readAllUrls(); 
    await backgrounds.readAllUrls();

    // Generate the image
    updatingFunction("Creating a new image...");
    int wallpaperWidth = wallpaper.width;
    int wallpaperHeight = wallpaper.height;
    Image finalImage = Image(width: wallpaperWidth, height: wallpaperHeight, numChannels: 4);

    // Evaluate the background
    WallpaperBackground? wallpaperBackground = wallpaper.background;
    if (wallpaperBackground != null) {
      
      updatingFunction("Working on background... setup...");
      Color backgroundColor = ColorFromString.fromString(wallpaperBackground.color);
      finalImage = fill(finalImage, color: backgroundColor);
      
      // Inject the src from name
      String? src = wallpaperBackground.src;
      String? name = wallpaperBackground.name;

      if(name != null && name.isNotEmpty) {
        PathUrl? backgroundSrc = backgrounds.search(name);
        if(backgroundSrc != null) {
            src = backgroundSrc.getFullPath();
        }
      }

      // If src is not null, try downloading the image.
      if(src != null && src.isNotEmpty) {
        updatingFunction("Working on background... convert the image...");
        
        // Try to fetch the already decoded image
        Image? backgroundSrcImage = await imageDatabase.fetchImage(src);

        // Decode the image
        if (backgroundSrcImage == null) { 
          updatingFunction("First time decoding the background, it may take a while...");
          ByteBuffer? resultBytes;

          final HttpRequest res = await HttpRequest.request(src, responseType: 'arraybuffer');
          if(res.status == 200){
            resultBytes = res.response as ByteBuffer;
          }

          if(resultBytes != null) {
            backgroundSrcImage = decodeImage(Uint8List.view(resultBytes));  
            if (backgroundSrcImage != null) {
              imageDatabase.saveImage(src, backgroundSrcImage);
            }
          }
        }
        
        // Apply the background image if valid
        if (backgroundSrcImage != null) {
          backgroundSrcImage = backgroundSrcImage.clone();
          finalImage.clear(ColorFromString.fromString(null)); // Apply default background color
          updatingFunction("Working on background... apply recoloring...");
          backgroundSrcImage = scaleRgba(backgroundSrcImage, scale: backgroundColor);
          updatingFunction("Working on background... apply the background...");
          finalImage = compositeImage(finalImage, backgroundSrcImage);
        }
      }
    }
    
    // Evaluate the logos
    List<WallpaperLogo>? wallpaperLogos = wallpaper.logos;
    if (wallpaperLogos != null) {
      for (int i = 0; i < wallpaperLogos.length; i++) {
        WallpaperLogo wallpaperLogo = wallpaperLogos[i];
        updatingFunction("Working on logo [${i + 1}/${wallpaperLogos.length}]... setup...");
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
          Image? logoSrcImage = await imageDatabase.fetchImage(src);

          // Decode the image
          if(logoSrcImage == null) {  
            updatingFunction("Decoding the logo [${i + 1}/${wallpaperLogos.length}]...");
            ByteBuffer? resultBytes;
            
            final HttpRequest res = await HttpRequest.request(src, responseType: 'arraybuffer');
            if(res.status == 200){
              resultBytes = res.response as ByteBuffer;
            }
            
            if(resultBytes != null) {
              logoSrcImage = decodeImage(Uint8List.view(resultBytes));  
              if (logoSrcImage != null) {
                imageDatabase.saveImage(src, logoSrcImage);
              }
            }
          }
          
          // The logo is not valid, to the next logo...
          if (logoSrcImage == null) continue;
          logoSrcImage = logoSrcImage.clone();

          // Apply the color by multiplication
          updatingFunction("Working on logo [${i + 1}/${wallpaperLogos.length}]... apply recoloring...");
          Color color = ColorFromString.fromString(wallpaperLogo.color);
          logoSrcImage = scaleRgba(logoSrcImage, scale: color, mask: logoSrcImage, maskChannel: Channel.alpha);

          // Calculate the final logo position
          int logoWidth = (logoSrcImage.width * size).toInt();
          int logoHeight = (logoSrcImage.height * size).toInt();

          double logoPosX = position?.x != null ? position!.x : 0.5;
          double logoPosY = position?.y != null ? position!.y : 0.5;
          
          double centerX = ((wallpaperWidth * logoPosX) - logoWidth / 2);
          double centerY = ((wallpaperHeight * logoPosY) - logoHeight / 2);

          updatingFunction("Working on logo [${i + 1}/${wallpaperLogos.length}]... apply the logo...");
          
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

    // Return the final image
    return finalImage.getBytes();
  }
}