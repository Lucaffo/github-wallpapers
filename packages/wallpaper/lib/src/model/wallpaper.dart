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
    
    int? width;
    int? height;
    WallpaperLogo? logo;
    WallpaperBackground? background;

    Wallpaper({
        this.width,
        this.height,
        this.logo,
        this.background,
    });

    factory Wallpaper.fromRawJson(String str) => Wallpaper.fromJson(json.decode(str));
    
    String toRawJson() => json.encode(toJson());

    factory Wallpaper.fromJson(Map<String, dynamic> json) => Wallpaper(
        width: json["width"],
        height: json["height"],
        logo: json["logo"] == null ? null : WallpaperLogo.fromJson(json["logo"]),
        background: json["background"] == null ? null : WallpaperBackground.fromJson(json["background"]),
    );

    Map<String, dynamic> toJson() => {
        "width": width,
        "height": height,
        "logo": logo?.toJson(),
        "background": background?.toJson(),
    };
}