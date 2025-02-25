import 'dart:convert';

/*
*   Wallpaper Background Class.
*   This represents the background of the wallpaper.
*
*   Luca Raffo @ 12/02/2025
*/ 
class WallpaperBackground {

    String? color;
    String? name;
    String? src;

    WallpaperBackground ({
      this.color, 
      this.name,
      this.src
    });

    factory WallpaperBackground.fromRawJson(String str) => WallpaperBackground.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory WallpaperBackground.fromJson(Map<String, dynamic> json) => WallpaperBackground(
        color: json["color"],
        name: json["name"],
        src: json["src"],
    );

    Map<String, dynamic> toJson() {
      var data = {
        "color": color,
        "name" : name,
        "src": src,
      };
      data.removeWhere((key, value) => value == null);
      return data;
    }
}
