import 'dart:math';
import 'dart:convert';

/*
*   Wallpaper Logo Position Class.
*   This is responsible for the relative position of the logo on the canvas.
*   Make sure the coordinates are clamped between 0..1.
*
*   Luca Raffo @ 04/02/2025
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
