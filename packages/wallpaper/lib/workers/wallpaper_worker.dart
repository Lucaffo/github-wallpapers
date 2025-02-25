import 'dart:typed_data';
import 'dart:convert';
import 'dart:html';

import 'package:wallpaper/wallpaper.dart';

class WallpaperWorker {

  // Message identifier to the main thread
  static const String deliveryMsg = "wallpaperBytes";
  static const String updatingMsg = "wallpaperUpdates";
  
  // Initialize the wallpaper worker (Execute this method inside the worker)
  static void initialize(){
    
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
          Wallpaper wallpaper = Wallpaper.fromRawJson(wallpaperRawJson);

          // Store here the result of the generation
          Uint8List? res = await wallpaper.generate(updatingFunction: sendUpdatingMsgToMain);;

          // Check the generation result
          if (res != null) {
            print("Wallpaper Generated, posted to main thread.");
            workerScope.postMessage({deliveryMsg : res }, [res.buffer]);
          } else {
            print("Wallpaper not Generated, something not doing well");
            workerScope.postMessage(null);
          }
        }
      }
    });
  }

  // Send a message toward the main thread
  static void sendUpdatingMsgToMain(String message){
    final DedicatedWorkerGlobalScope workerScope = DedicatedWorkerGlobalScope.instance;
    workerScope.postMessage({updatingMsg : message});
  }
}