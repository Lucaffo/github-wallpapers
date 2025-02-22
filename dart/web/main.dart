import 'dart:convert';
import 'dart:math';
import 'dart:html';
import 'dart:async';

import 'package:code_mirror/code_mirror.dart';
import 'package:dart/views/wallpaper_canvas.dart';
import 'package:wallpaper/wallpaper.dart';

final ButtonElement saveBtn = document.querySelector("#save-btn") as ButtonElement;

final CodeMirrorEditor codeEditor = CodeMirrorEditor("#input");

const int numberOfConfigurations = 7;
Timer? _debounceTimer;

final WallpaperCanvas canvas = WallpaperCanvas("output");

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
  saveBtn.onClick.listen((_) => canvas.saveImage());
  codeEditor.onChange(debounceUpdateWallpaper);
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

void updateCanvas(Wallpaper? wallpaper) {
  if (wallpaper == null) return;
  canvas.setWallpaper(wallpaper);
}

Uri getRandomInitialConfiguration() {
  int index = Random.secure().nextInt(numberOfConfigurations) + 1;
  return Uri.parse("https://lucaffo.github.io/github-wallpapers/static/wallpapers/wallpaper_${index.toString().padLeft(2, '0')}.json");
}