import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:wallpaper/storage/serializable_image.dart';
import 'package:worker_persistency/worker_database.dart';

/*
 * This class is capable of storing already decoded images into the DB.
 * Retrieving already decoded images improves the performance a LOT.
 * 
 * Also it has duration mechanism where the data is discarded after a time.
 * 
 * 21/02/2025 @ Luca Raffo
 */
class DecodedImageStorage {

  Duration cacheDuration = Duration(hours: 3);
  WorkerDatabase imageDatabase = WorkerDatabase<dynamic, String>("Images", "Decoded");

  DecodedImageStorage({Duration? cacheDuration}){
    if(cacheDuration != null) this.cacheDuration = cacheDuration;
  }
  
  // Fetch the Image Object from the DB, handling all the data conversion
  Future<Image?> fetchImage(String key) async {
    dynamic jsMap = await imageDatabase.tryFetch(key);
    Map<String, dynamic> map = Map.from(jsMap == null ? Map.identity() : Map.from(jsMap));
    if(map.isNotEmpty) {

      SerializableImage cachedBackground = SerializableImage.fromJson(map);

      // Make sure is valid
      if(DateTime.now().difference(cachedBackground.time) >= cacheDuration) {

        // Remove the entry from the db
        await imageDatabase.tryDelete(key, motivation: "expired");
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

      imageDatabase.tryPut(key, SerializableImage(
        time: DateTime.now(),
        width: image.width, 
        height: image.height, 
        buffer: rawBytes.buffer).toJson());
    }
  }
}