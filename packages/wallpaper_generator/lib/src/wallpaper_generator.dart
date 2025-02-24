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
    WallpaperImageDatabase imageDatabase = WallpaperImageDatabase("ImagesDB", "ImageStore", cacheDuration: Duration(minutes: 5));

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
      
      // Take out all the parameters from the background
      String? src = wallpaperBackground.src;
      String? name = wallpaperBackground.name;
      String? color = wallpaperBackground.color;

      // Compute the colors
      color ??= "rgba(255, 255, 255, 1.0)"; // Make sure default multiply color is white
      Color defaultColor = ColorFromString.fromString("rgba(0, 0, 0, 1)");
      Color multiplyColor = ColorFromString.fromString(color);

      // Inject the src from name
      if(name != null && name.isNotEmpty) {
        PathUrl? backgroundSrc = backgrounds.search(name);
        if(backgroundSrc != null) {
            src = backgroundSrc.getFullPath();
        }
      }
      
      // Apply the background color
      finalImage = fill(finalImage, color: multiplyColor);

      // If src is not null, try downloading the image.
      if(src != null && src.isNotEmpty) {
        
        // Try to fetch the already decoded image
        updatingFunction("Try to fetch background from cache...");
        Image? backgroundSrcImage = await imageDatabase.fetchImage(src);

        // Download and decode the image for the first times
        if (backgroundSrcImage == null) {
          ByteBuffer? resultBytes;
          
          updatingFunction("Loading the background...");
          final HttpRequest res = await HttpRequest.request(src, responseType: 'arraybuffer');
          if(res.status == 200){
            resultBytes = res.response as ByteBuffer;
          }

          updatingFunction("First time decoding the background, it may take a while...");
          if(resultBytes != null) {
            backgroundSrcImage = decodeImage(Uint8List.view(resultBytes));  
            if (backgroundSrcImage != null) {
              imageDatabase.saveImage(src, backgroundSrcImage);
            }
          }
        }
        
        // Apply the background image if valid
        if (backgroundSrcImage != null) {
          finalImage.clear(defaultColor);
          updatingFunction("Recoloring the background...");
          backgroundSrcImage = scaleRgba(backgroundSrcImage, scale: multiplyColor);
          updatingFunction("Apply the background...");
          finalImage = compositeImage(finalImage, backgroundSrcImage);
        }
      }
    }
    
    // Evaluate the logos
    List<WallpaperLogo>? wallpaperLogos = wallpaper.logos;
    if (wallpaperLogos != null) {
      for (int i = 0; i < wallpaperLogos.length; i++) {

        // Take out all the parameters from the logo
        WallpaperLogo wallpaperLogo = wallpaperLogos[i];
        String? src;
        String? type = wallpaperLogo.type;
        String? name = wallpaperLogo.name;
        double? size = wallpaperLogo.size;
        String? color = wallpaperLogo.color;
        WallpaperLogoPosition? position = wallpaperLogo.position;

        // Inject the src from name
        PathUrl? path;
        if(name != null && name.isNotEmpty && type != null && type.isNotEmpty) {
          switch(type)
          {
            case "octocat":
              path = octocats.search(name);
              break;
            case "logo":
              path = logos.search(name);
              break;
          }
        }
        
        if(path != null) {
          src = path.getFullPath();
        }

        // If src is not null, try downloading the image.
        if(src != null && src.isNotEmpty) {

          // Try to hit the image from cache or get via http
          updatingFunction("Try to fetch logo '${path!.getFileName(false)}' from cache...");
          Image? logoSrcImage = await imageDatabase.fetchImage(src);

          // Decode the image
          if(logoSrcImage == null) {  
            ByteBuffer? resultBytes;
            
            updatingFunction("Fetch the logo '${path.getFileName(false)}' from the web...");
            final HttpRequest res = await HttpRequest.request(src, responseType: 'arraybuffer');
            if(res.status == 200){
              resultBytes = res.response as ByteBuffer;
            }
            
            updatingFunction("First time decoding the logo '${path.getFileName(false)}', it may take a while...");
            if(resultBytes != null) {
              logoSrcImage = decodeImage(Uint8List.view(resultBytes));  
              if (logoSrcImage != null) {
                imageDatabase.saveImage(src, logoSrcImage);
              }
            }
          }
          
          // The logo is not valid, to the next logo...
          if (logoSrcImage == null) continue;

          // Apply the color by multiplication
          updatingFunction("Recoloring of logo '${path.getFileName(false)}'...");
          color ??= "rgba(255, 255, 255, 1.0)"; // make sure default is white
          logoSrcImage = scaleRgba(logoSrcImage,
            scale: ColorFromString.fromString(color),
            mask: logoSrcImage,
            maskChannel: Channel.alpha);

          // Calculate the final logo position
          size ??= 1.0; // make sure default is 1.0
          int logoWidth = (logoSrcImage.width * size).toInt();
          int logoHeight = (logoSrcImage.height * size).toInt();

          double logoPosX = position?.x != null ? position!.x : 0.5;
          double logoPosY = position?.y != null ? position!.y : 0.5;
          
          double centerX = ((wallpaperWidth * logoPosX) - logoWidth / 2);
          double centerY = ((wallpaperHeight * logoPosY) - logoHeight / 2);

          updatingFunction("Apply the logo '${path.getFileName(false)}'...");
          
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