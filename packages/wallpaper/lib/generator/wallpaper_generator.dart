import 'package:image/image.dart';
import 'package:wallpaper/utils/send_port.dart';
import 'package:wallpaper/wallpaper.dart';
import 'package:wallpaper/utils/color_from_string.dart';
import 'package:paths_collection/path_collection.dart';
import 'package:paths_collection/path_url.dart';
import 'package:wallpaper/storage/decoded_image_storage.dart';
import 'dart:html';
import 'dart:typed_data';

class WallpaperGenerator {

  static final PathCollection logos = PathCollection("https://lucaffo.github.io/github-wallpapers/static/logos/paths.json");
  static final PathCollection octocats = PathCollection("https://lucaffo.github.io/github-wallpapers/static/octocats/paths.json");
  static final PathCollection backgrounds = PathCollection("https://lucaffo.github.io/github-wallpapers/static/backgrounds/paths.json");
  
  static Future<Uint8List?> generateWallpaper(Wallpaper wallpaper, Function(String)? updatingFunction) async {

    // Fetch the imageDB for image caching
    DecodedImageStorage decodedImages = DecodedImageStorage();
    SendPort<String> caller = SendPort<String>(updatingFunction);

    // Make sure to load all the urls
    caller.send("Loading all the paths resources...");
    await logos.readAllUrls();
    await octocats.readAllUrls(); 
    await backgrounds.readAllUrls();

    // Generate the image
    caller.send("Creating a new image...");
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
      Color defaultColor = "rgba(0, 0, 0, 1)".toColor();
      Color multiplyColor = color.toColor();

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
        caller.send("Try to fetch background from cache...");
        Image? backgroundSrcImage = await decodedImages.fetchImage(src);

        // Download and decode the image for the first times
        if (backgroundSrcImage == null) {
          ByteBuffer? resultBytes;
          
          caller.send("Loading the background...");
          final HttpRequest res = await HttpRequest.request(src, responseType: 'arraybuffer');
          if(res.status == 200){
            resultBytes = res.response as ByteBuffer;
          }

          caller.send("First time decoding the background, it may take a while...");
          if(resultBytes != null) {
            backgroundSrcImage = decodeImage(Uint8List.view(resultBytes));  
            if (backgroundSrcImage != null) {
              decodedImages.saveImage(src, backgroundSrcImage);
            }
          }
        }
        
        // Apply the background image if valid
        if (backgroundSrcImage != null) {
          finalImage.clear(defaultColor);
          caller.send("Recoloring the background...");
          backgroundSrcImage = scaleRgba(backgroundSrcImage, scale: multiplyColor);
          caller.send("Apply the background...");
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
          caller.send("Try to fetch logo '${path!.getFileName(false)}' from cache...");
          Image? logoSrcImage = await decodedImages.fetchImage(src);

          // Decode the image
          if(logoSrcImage == null) {  
            ByteBuffer? resultBytes;
            
            caller.send("Fetch the logo '${path.getFileName(false)}' from the web...");
            final HttpRequest res = await HttpRequest.request(src, responseType: 'arraybuffer');
            if(res.status == 200){
              resultBytes = res.response as ByteBuffer;
            }
            
            caller.send("First time decoding the logo '${path.getFileName(false)}', it may take a while...");
            if(resultBytes != null) {
              logoSrcImage = decodeImage(Uint8List.view(resultBytes));  
              if (logoSrcImage != null) {
                decodedImages.saveImage(src, logoSrcImage);
              }
            }
          }
          
          // The logo is not valid, to the next logo...
          if (logoSrcImage == null) continue;

          // Apply the color by multiplication
          caller.send("Recoloring of logo '${path.getFileName(false)}'...");
          color ??= "rgba(255, 255, 255, 1.0)"; // make sure default is white
          logoSrcImage = scaleRgba(logoSrcImage,
            scale: color.toColor(),
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

          caller.send("Apply the logo '${path.getFileName(false)}'...");
          
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