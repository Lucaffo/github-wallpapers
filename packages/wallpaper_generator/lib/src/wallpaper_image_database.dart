import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:wallpaper_generator/src/wallpaper_serializable_image.dart';
import 'package:worker_persistency/src/worker_database.dart';

/*
 * This class is capable of storing already decoded images into the DB.
 * Retrieving already decoded images improves the performance a LOT.
 * 
 * 21/02/2025 @ Luca Raffo
 */
class WallpaperImageDatabase extends WorkerDatabase<dynamic, String> {

  Duration cacheDuration = Duration(days: 1);
  WorkerDatabase decodedImageDB = WorkerDatabase<dynamic, String>("DecodedImagesDB", "DecodedImageStore");

  WallpaperImageDatabase(super.dbName, super.storeName, {Duration? cacheDuration}){
    if(cacheDuration != null) this.cacheDuration = cacheDuration;
  }

  // Fetch the Image Object from the DB, handling all the data conversion
  Future<Image?> fetchImage(String key) async {
    dynamic jsMap = await decodedImageDB.tryFetch(key);
    Map<String, dynamic> map = Map.from(jsMap == null ? Map.identity() : Map.from(jsMap));
    if(map.isNotEmpty) {

      WallpaperSerializableImage cachedBackground = WallpaperSerializableImage.fromJson(map);

      // Make sure is valid
      if(DateTime.now().difference(cachedBackground.time) >= cacheDuration) {

        // Remove the entry from the db
        await decodedImageDB.tryDelete(key);
        return null;
      }

      // Reset the time if the resource is already available but used
      cachedBackground.time = DateTime.now();

      // Clean the buffer in a way that offsets are removed
      final int expectedLength = cachedBackground.width * cachedBackground.height * 4;  // assumendo 4 canali
      Uint8List rawBytes = Uint8List.view(cachedBackground.buffer, 0, expectedLength);
      Uint8List cleanBytes = Uint8List.fromList(rawBytes);

      // Return the image from bytes
      return Image.fromBytes( 
        width: cachedBackground.width,
        height: cachedBackground.height, 
        bytes: cleanBytes.buffer,
        numChannels: 4);
    }

    return null;
  }

  // Save an image to the DB
  void saveImage(String key, Image? image){
    if (image != null) {

      // Convert the saved image into a retrievable format
      image = image.convert(format: Format.uint8, numChannels: 4);

      // Make sure to get the raw data
      Uint8List rawBytes = Uint8List.fromList(image.getBytes());

      decodedImageDB.tryPut(key, WallpaperSerializableImage(
        time: DateTime.now(),
        width: image.width, 
        height: image.height, 
        buffer: rawBytes.buffer).toJson());
    }
  }
}