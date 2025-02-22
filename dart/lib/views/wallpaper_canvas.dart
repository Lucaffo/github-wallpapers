import 'dart:html';

import 'package:wallpaper/wallpaper.dart';

// The worker compiled name for wallpaper generation
final String workerName = "wallpaper_generator_worker.js";

/*
* Wallpaper Canvas Class
* Handle multiple methods for the wallpaper canvas.
*/
class WallpaperCanvas {

  Worker? worker;
  String canvasName;

  // Set the wallpaper components
  late CanvasElement canvas;
  late OffscreenCanvas offscreenCanvas;
  late OffscreenCanvasRenderingContext2D offCtx;

  // Loading panel and Loading message
  late DivElement loading;
  late ParagraphElement loadingMessage;

  // Set all the canvas components using the name
  WallpaperCanvas(this.canvasName) {
    canvas = querySelector("#$canvasName") as CanvasElement;
    offscreenCanvas = canvas.transferControlToOffscreen();
    offCtx = offscreenCanvas.getContext('2d') as OffscreenCanvasRenderingContext2D;
    loading = document.querySelector("#$canvasName-loading-panel") as DivElement;
    loadingMessage = document.querySelector("#$canvasName-loading-message") as ParagraphElement;
  }

  /**
   * Set the wallpaper of the canvas
   * This will call an external worker that generate and set
   * the canvas image. If called before the generation, it will discard the
   * previous worker and start a new generation.
   */
  void setWallpaper(Wallpaper wallpaper) {
    loading.style.visibility = "visible";
    worker?.terminate();
    worker = Worker(workerName);
    worker?.onMessage.listen((MessageEvent event) {

      if (event.data is Map && event.data.containsKey('wallpaperUpdates')) {
        loadingMessage.text = event.data['wallpaperUpdates'];
        return;
      }

      if (event.data is Map && event.data.containsKey('wallpaperBytes')) {
        offscreenCanvas.width = wallpaper.width;
        offscreenCanvas.height = wallpaper.height;
        ImageData imageData = offCtx.createImageData(wallpaper.width, wallpaper.height);
        imageData.data.setAll(0, event.data['wallpaperBytes']);
        offCtx.putImageData(imageData, 0, 0);
      }

      loading.style.visibility = "hidden";
    });
    worker?.postMessage({'wallpaper' : wallpaper.toJson()});
  }

  /**
   * Create and click a virtual anchor to download a file.
   * It's based on the current state of the canvas.
   */
  void saveImage() {
    print("Wallpaper Save");
    String dataUrl = canvas.toDataUrl('image/png');

    final anchor = AnchorElement(href: dataUrl)
      ..target = 'blank'
      ..download = 'canvas_image.png';

    anchor.click();
  }
}