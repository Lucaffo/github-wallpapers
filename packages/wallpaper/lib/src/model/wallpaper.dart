import 'dart:convert';
import 'wallpaper_background.dart';
import 'wallpaper_logo.dart';

/*
*   Wallpaper Class.
*   This represents the actual wallpaper.
*
*   Luca Raffo @ 12/02/2025
*/ 
class Wallpaper {
    
    int width;
    int height;
    List<WallpaperLogo>? logos;
    WallpaperBackground? background;

    Wallpaper({
        required this.width,
        required this.height,
        this.logos,
        this.background,
    });

    factory Wallpaper.fromRawJson(String str) => Wallpaper.fromJson(json.decode(str));
    
    String toRawJson() => json.encode(toJson());

    factory Wallpaper.fromJson(Map<String, dynamic> jsonContent) => Wallpaper(
        width: jsonContent["width"],
        height: jsonContent["height"],
        logos: jsonContent["logos"] != null ? (jsonContent["logos"] as List).map((i) => WallpaperLogo.fromJson(i)).toList() : null,
        background: jsonContent["background"] == null ? null : WallpaperBackground.fromJson(jsonContent["background"]),
    );

    Map<String, dynamic> toJson() {
      var data = {
        "width": width,
        "height": height,
        "logos": logos?.map((i) => i.toJson()).toList(),
        "background": background?.toJson(),
      };
      data.removeWhere((key, value) => value == null);
      return data;
    }

}