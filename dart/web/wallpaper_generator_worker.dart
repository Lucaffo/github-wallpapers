import 'dart:typed_data';
import 'dart:convert';

import 'dart:html';
import 'package:wallpaper/wallpaper.dart';
import 'package:wallpaper_generator/wallpaper_generator.dart';
import 'package:image/image.dart' as img;

void main() {
  
  // Get the worker scope
  final DedicatedWorkerGlobalScope workerScope = DedicatedWorkerGlobalScope.instance;

  // Listen for any message
  workerScope.onMessage.listen((MessageEvent event) async {

    var data = event.data;

    // Map the inputs from the message event
    if (data is Map) {
      
      // Generate and post the wallpaper bitmap as response
      if (data['wallpaper'] != null) {
        String wallpaperRawJson = jsonEncode(data['wallpaper']);
        Wallpaper? wallpaper = Wallpaper.fromRawJson(wallpaperRawJson);
        Uint8List? res = await generateWallpaper(wallpaper);
        if (res != null) {
          print("Wallpaper Generated, posted to main thread.");
          workerScope.postMessage({'wallpaperBytes' : res }, [res.buffer]);
        } else {
          print("Wallpaper not Generated, something not doing well");
          workerScope.postMessage(null);
        }
      }
    }
  });
}

// Generate the wallpaper into a byte array
// this format is friendly to postMessage despite BitmapImage or OffscreenCanvas
// cause for some reason in dart this object are set to null after despite they
// are "transferable"... idk. Bruteforcing to Uint8List works like a charm.
Future<Uint8List?> generateWallpaper(Wallpaper? wallpaper) async {
  
  // Check if the wallpaper is not null
  if (wallpaper == null) {
    print("Wallpaper is null, cannot generate a null wallpaper.");
    return null;
  }

  // Generate the wallpaper
  img.Image? image = await WallpaperGenerator.generateWallpaper(wallpaper);
  if (image == null) {
    print("Generated image is null, there it was an error in the wallpaper generation.");
    return null;
  }
  
  // Get the bytes and the data
  final Uint8List imageBytes = image.getBytes();
  return imageBytes;
}