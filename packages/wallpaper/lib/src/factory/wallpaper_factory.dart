import '../model/wallpaper.dart';

abstract class WallpaperFactory<T> {
  Future<Wallpaper?> getWallpaper(T param);
}