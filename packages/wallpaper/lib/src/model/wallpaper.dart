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
        this.logos = const[],
        this.background,
    });

    factory Wallpaper.fromRawJson(String str) => Wallpaper.fromJson(json.decode(str));
    
    String toRawJson() => json.encode(toJson());

    factory Wallpaper.fromJson(Map<String, dynamic> jsonContent) => Wallpaper(
        width: jsonContent["width"],
        height: jsonContent["height"],
        logos: jsonContent["logos"] == null ? null : List<WallpaperLogo>.from(jsonContent["logos"]!.map((x) => WallpaperLogo.fromJson(x))),
        background: jsonContent["background"] == null ? null : WallpaperBackground.fromJson(jsonContent["background"]),
    );

    Map<String, dynamic> toJson() => {
        "width": width,
        "height": height,
        "logos": logos == null ? [] : List<dynamic>.from(logos!.map((x) => x.toJson())),
        "background": background?.toJson(),
    };
}