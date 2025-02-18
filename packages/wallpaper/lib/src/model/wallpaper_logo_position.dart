import 'dart:math';
import 'dart:convert';

/*
*   Wallpaper Logo Position Class.
*   This represents a logo position.
*
*   Luca Raffo @ 12/02/2025
*/ 
class WallpaperLogoPosition {

    double x;
    double y;
   
    WallpaperLogoPosition ({
      this.x = 0.5,
      this.y = 0.5
    });
    
    factory WallpaperLogoPosition.fromRawJson(String str) => WallpaperLogoPosition.fromJson(json.decode(str));

    factory WallpaperLogoPosition.fromJson(Map<String, dynamic> json) => WallpaperLogoPosition (
        x: min(max(json["x"]?.toDouble(), 0), 1),
        y: min(max(json["y"]?.toDouble(), 0), 1)
    );

    String toRawJson() => json.encode(toJson());

    Map<String, dynamic> toJson() => {
        "x": x,
        "y": y,
    };
}
