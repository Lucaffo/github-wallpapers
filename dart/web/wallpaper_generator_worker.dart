import 'dart:typed_data';
import 'dart:convert';

import 'dart:html';

import 'package:wallpaper/wallpaper.dart';
import 'package:wallpaper_generator/wallpaper_generator.dart';
import 'package:worker_database/worker_database.dart';

void main() {

  // Database for already generated wallpaper
  WorkerDatabase wdb = WorkerDatabase<ByteBuffer, String>("WallpaperDB", "wallpaperBytesData");
  
  // Get the worker scope
  final DedicatedWorkerGlobalScope workerScope = DedicatedWorkerGlobalScope.instance;

  // Listen for any message
  workerScope.onMessage.listen((MessageEvent event) async {

    var data = event.data;

    // Map the inputs from the message event
    if (data is Map) {
      
      // Generate and post the wallpaper bitmap as response
      if (data['wallpaper'] != null) {

        // Generate the wallpaper object
        String wallpaperRawJson = jsonEncode(data['wallpaper']);
        Wallpaper? wallpaper = Wallpaper.fromRawJson(wallpaperRawJson);

        // Fetch already generated if any
        ByteBuffer? resCache = await wdb.tryFetch(wallpaper.toRawJson()); 
        if(resCache != null){
          print("Wallpaper Cache Hit from DB, posted to main thread.");
          Uint8List byteArray = Uint8List.view(resCache);
          workerScope.postMessage({'wallpaperBytes' : byteArray }, [byteArray.buffer]);
          return;
        }

        // Generate the wallpaper
        Uint8List? res = await generateWallpaper(wallpaper);
        if (res != null) {
          print("Wallpaper Generated, posted to main thread.");
          await wdb.tryPut(wallpaper.toRawJson(), res.buffer);
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
  Uint8List? imageBytes = await WallpaperGenerator.generateWallpaper(wallpaper);
  if (imageBytes == null) {
    print("Generated image is null, there it was an error in the wallpaper generation.");
    return null;
  }

  return imageBytes;
}