import 'dart:convert';
import 'dart:math';
import 'dart:html';
import 'dart:async';

import 'package:code_mirror/code_mirror.dart';
import 'package:wallpaper/wallpaper.dart';

final CanvasElement canvas = querySelector("#output") as CanvasElement;
final OffscreenCanvas offscreenCanvas = canvas.transferControlToOffscreen();
final OffscreenCanvasRenderingContext2D offCtx = offscreenCanvas.getContext('2d') as OffscreenCanvasRenderingContext2D;

final ButtonElement saveBtn = document.querySelector("#save-btn") as ButtonElement;
final DivElement loading = document.querySelector("#loading-panel") as DivElement;
final ParagraphElement loadingMessage = document.querySelector("#loading-message") as ParagraphElement;

final CodeMirrorEditor codeEditor = CodeMirrorEditor("#input");

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
  saveBtn.onClick.listen((_) => saveImage());
  codeEditor.onChange(debounceUpdateWallpaper);
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
  String? compactJson = codeEditor.getValue();
  if (compactJson == null) return;
  Wallpaper? wallpaper = Wallpaper.fromRawJson(compactJson);
  updateCanvas(wallpaper);
}

void setWallpaper(Wallpaper? wallpaper) {
  if (wallpaper == null) return;
  setJsonInCodeMirror(wallpaper.toRawJson());
  updateCanvas(wallpaper);
}

void setJsonInCodeMirror(String? jsonString) {
  if (jsonString == null) return;
  Map<String, dynamic>? map = json.decoder.convert(jsonString);
  if (map == null) return;
  JsonEncoder encoder = JsonEncoder.withIndent('  ');
  String prettyprint = encoder.convert(map);
  codeEditor.setValue(prettyprint);
}


// Stop the current worker and start another one
void updateCanvas(Wallpaper? wallpaper) {
  if (wallpaper == null) return;
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

Uri getRandomInitialConfiguration() {
  int index = Random.secure().nextInt(numberOfConfigurations) + 1;
  return Uri.parse("https://lucaffo.github.io/github-wallpapers/static/wallpapers/wallpaper_${index.toString().padLeft(2, '0')}.json");
}