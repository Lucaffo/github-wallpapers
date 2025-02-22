import 'dart:math';
import 'dart:html';
import 'dart:async';

import 'package:dart/views/wallpaper_canvas.dart';
import 'package:dart/views/wallpaper_code_editor.dart';
import 'package:wallpaper/wallpaper.dart';

final ButtonElement saveBtn = document.querySelector("#save-btn") as ButtonElement;

const int numberOfConfigurations = 7;
Timer? _debounceTimer;

final WallpaperCanvas canvas = WallpaperCanvas("output");
final WallpaperCodeEditor editor = WallpaperCodeEditor("input");

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

Uri getRandomInitialConfiguration() {
  int index = Random.secure().nextInt(numberOfConfigurations) + 1;
  return Uri.parse("https://lucaffo.github.io/github-wallpapers/static/wallpapers/wallpaper_${index.toString().padLeft(2, '0')}.json");
}

void bindUI() {
  saveBtn.onClick.listen((_) => canvas.saveImage());
  editor.onChange(debounceRefreshWallpaper);
}

void debounceRefreshWallpaper() {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(Duration(milliseconds: 1000), () => refreshWallpaper());
}

void refreshWallpaper() {
  print("Wallpaper Refresh");
  Wallpaper? wallpaper = editor.getWallpaper();
  if(wallpaper == null) return;
  canvas.setWallpaper(wallpaper);
}

void setWallpaper(Wallpaper? wallpaper) {
  if (wallpaper == null) return;
  editor.setWallpaper(wallpaper);
  canvas.setWallpaper(wallpaper);
}