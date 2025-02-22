import 'dart:convert';
import 'wallpaper_logo_position.dart';

/*
*   Wallpaper Logo Class.
*   This represents a logo inside the wallpaper.
*
*   Luca Raffo @ 12/02/2025
*/ 
class WallpaperLogo
{
    String? type;
    String? name;
    double? size;
    WallpaperLogoPosition? position;
    String? color;

    WallpaperLogo({
        this.type,
        this.name,
        this.size = 1,
        this.position,
        this.color,
    });

    factory WallpaperLogo.fromRawJson(String str) => WallpaperLogo.fromJson(json.decode(str));

    factory WallpaperLogo.fromJson(Map<String, dynamic> json) => WallpaperLogo (
        type: json["type"],
        name: json["name"],
        size: json["size"]?.toDouble(),
        position: json["position"] == null ? null : WallpaperLogoPosition.fromJson(json["position"]),
        color: json["color"],
    );

    String toRawJson() => json.encode(toJson());

    Map<String, dynamic> toJson() {
      var data = {
        "type": type,
        "name": name,
        "size": size,
        "position": position?.toJson(),
        "color": color,
      };
      data.removeWhere((key, value) => value == null);
      return data;
    }
}