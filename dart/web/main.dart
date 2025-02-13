import 'dart:async';
import 'dart:html';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:wallpaper/wallpaper.dart';
import 'package:wallpaper_generator/wallpaper_generator.dart';

import 'package:image/image.dart' as img;
import 'package:worker_manager/worker_manager.dart';

const String canvasId = "#output";
const String textAreaId = "#input";
const String saveBtnId = "#save-btn";
const String loadingId = "#loading";

const int numberOfConfigurations = 7;

Cancelable? cancelable;
Timer? _debounceTimer;

final CanvasElement canvas = querySelector(canvasId) as CanvasElement;
final OffscreenCanvas offscreenCanvas = canvas.transferControlToOffscreen();
final OffscreenCanvasRenderingContext2D offCtx = offscreenCanvas.getContext('2d') as OffscreenCanvasRenderingContext2D;
final TextAreaElement textArea = querySelector(textAreaId) as TextAreaElement;
final DivElement loading = querySelector(loadingId) as DivElement;
final ButtonElement saveBtn = querySelector(saveBtnId) as ButtonElement;

void main() async {

  // Set first wallpaper
  setFirstWallpaper();

  // Bind the UI
  bindUI();
}

void setFirstWallpaper() async {
  HTTPWallpaperFactory httpWallpaperFactory = HTTPWallpaperFactory();
  Wallpaper? wallpaper = await httpWallpaperFactory.getWallpaper(getRandomInitialConfiguration());
  setWallpaper(wallpaper);
}

void bindUI() {
  textArea.onChange.listen((_) => debounceUpdateWallpaper());
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
  _debounceTimer = Timer(Duration(milliseconds: 500), () => updateWallpaper());
}

void updateWallpaper() async {
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

void updateCanvas(Wallpaper? wallpaper) async {
  if (wallpaper == null) return;

  loading.style.display = "block";
  
  offscreenCanvas.width = wallpaper.width;
  offscreenCanvas.height = wallpaper.height;

  await workerManager.execute(() async {
      img.Image? image = await WallpaperGenerator.generateWallpaper(wallpaper);
      if (image == null) return;
      final Uint8List imageBytes = image.getBytes();
      final ImageData imageData = offCtx.createImageData(image.width, image.height);
      imageData.data.setAll(0, imageBytes);
      offCtx.putImageData(imageData, 0, 0);
  });

  loading.style.display = "none";
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