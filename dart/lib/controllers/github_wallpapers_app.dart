import 'dart:async';
import 'dart:html';
import 'dart:math';
import 'package:dart/views/wallpaper_canvas.dart';
import 'package:dart/views/wallpaper_code_editor.dart';
import 'package:wallpaper/wallpaper.dart';

/**
 * The Github Wallpaper App
 * This is the main controller of the application lifecycle.
 * 
 * 22/02/2025 @ Luca Raffo
 */
class GithubWallpapersApp {

  static const int numberOfConfigurations = 7;
  Timer? _debounceTimer;
  
  final ButtonElement saveBtn = document.querySelector("#save-btn") as ButtonElement;
  final ButtonElement randomizeBtn = document.querySelector("#rnd-btn") as ButtonElement;

  final WallpaperCanvas canvas = WallpaperCanvas("output");
  final WallpaperCodeEditor editor = WallpaperCodeEditor("input");

  Future setFirstWallpaper() async {
    await setRandomWallpaperFromConfigurations();
  }

  void bindUI() {
    editor.onChange(debounceRefreshWallpaper);
    saveBtn.onClick.listen((_) => canvas.saveImage());
    randomizeBtn.onClick.listen((_) async {
      await setRandomWallpaperFromConfigurations();
    });
  }

  void debounceRefreshWallpaper() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 1000), () => refreshWallpaper());
  }
  
  Future setRandomWallpaperFromConfigurations() async {
    HTTPWallpaperFactory httpWallpaperFactory = HTTPWallpaperFactory();
    Wallpaper? wallpaper = await httpWallpaperFactory.getWallpaper(getRandomInitialConfiguration());
    setWallpaper(wallpaper);
  }

  Uri getRandomInitialConfiguration() {
    int index = Random.secure().nextInt(numberOfConfigurations) + 1;
    return Uri.parse("https://lucaffo.github.io/github-wallpapers/static/wallpapers/wallpaper_${index.toString().padLeft(2, '0')}.json");
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
}