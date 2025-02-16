import 'dart:convert';
import 'dart:math';
import 'dart:html';
import 'dart:async';

import 'package:wallpaper/wallpaper.dart';

final CanvasElement canvas = querySelector("#output") as CanvasElement;
final OffscreenCanvas offscreenCanvas = canvas.transferControlToOffscreen();
final OffscreenCanvasRenderingContext2D offCtx = offscreenCanvas.getContext('2d') as OffscreenCanvasRenderingContext2D;

final TextAreaElement textArea = document.querySelector("#input") as TextAreaElement;
final ButtonElement saveBtn = document.querySelector("#save-btn") as ButtonElement;
final DivElement loading = document.querySelector("#loading-panel") as DivElement;

const int numberOfConfigurations = 7;
Timer? _debounceTimer;

final String workerName = "wallpaper_generator_worker.js";
Worker? worker;

void main() async {

  // Set first wallpaper
  await setFirstWallpaper();

  // Bind the UI
  bindUI();
}

Future setFirstWallpaper() async {
  HTTPWallpaperFactory httpWallpaperFactory = HTTPWallpaperFactory();
  Wallpaper? wallpaper = await httpWallpaperFactory.getWallpaper(getRandomInitialConfiguration());
  setWallpaper(wallpaper);
}

void bindUI() {
  textArea.onInput.listen((_) => debounceUpdateWallpaper());
  saveBtn.onClick.listen((_) => saveImage());
}

void saveImage() {
  print("Wallpaper Save");
  String dataUrl = canvas.toDataUrl('image/png');

  final anchor = AnchorElement(href: dataUrl)
    ..target = 'blank'
    ..download = 'canvas_image.png';

  anchor.click();
}

void debounceUpdateWallpaper() {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(Duration(milliseconds: 1500), () => updateWallpaper());
}

void updateWallpaper() {
  print("Wallpaper Update");
  String compactJson = getJsonFromTextArea();
  Wallpaper? wallpaper = Wallpaper.fromRawJson(compactJson);
  setWallpaper(wallpaper);
}

void setWallpaper(Wallpaper? wallpaper) {
  if (wallpaper == null) return;
  setJsonInTextArea(wallpaper.toRawJson());
  updateCanvas(wallpaper);
}

void setJsonInTextArea(String? jsonString) {
  if (jsonString == null) return;
  Map<String, dynamic>? map = json.decoder.convert(jsonString);
  if (map == null) return;
  JsonEncoder encoder = JsonEncoder.withIndent('  ');
  String prettyprint = encoder.convert(map);
  textArea.text = prettyprint;
}

// Stop the current worker and start another one
void updateCanvas(Wallpaper? wallpaper) {
  if (wallpaper == null) return;
  loading.style.visibility = "visible";
  worker?.terminate();
  worker = Worker(workerName);
  worker?.onMessage.listen((MessageEvent event) {

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

String getJsonFromTextArea() {
  String jsonString = textArea.value!.trim();
  Map<String, dynamic> jsonData = jsonDecode(jsonString);
  return jsonEncode(jsonData);
}

Uri getRandomInitialConfiguration() {
  int index = Random.secure().nextInt(numberOfConfigurations) + 1;
  return Uri.parse("https://lucaffo.github.io/github-wallpapers/static/wallpapers/wallpaper_${index.toString().padLeft(2, '0')}.json");
}