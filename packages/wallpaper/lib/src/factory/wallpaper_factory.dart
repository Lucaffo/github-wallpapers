import '../model/wallpaper.dart';

/*
* Abstract factory class to create a wallpaper data model.
* Luca Raffo @ 12/02/2025 
*/
abstract class WallpaperFactory<T> {
  Future<Wallpaper?> getWallpaper(T param);
}