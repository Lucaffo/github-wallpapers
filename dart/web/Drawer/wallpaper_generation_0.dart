import 'dart:html';
import 'dart:convert';

import 'wallpaper_background_drawer.dart';
import 'wallpaper_drawer.dart';
import 'wallpaper_logo_drawer.dart';

class WallpaperGeneration0 extends WallpaperDrawer {
    
    int? width;
    int? height;
    WallpaperLogoDrawer? logo;
    WallpaperBackgroundDrawer? background;

    WallpaperGeneration0({
        this.width,
        this.height,
        this.logo,
        this.background,
    });

    factory WallpaperGeneration0.fromRawJson(String str) => WallpaperGeneration0.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory WallpaperGeneration0.fromJson(Map<String, dynamic> json) => WallpaperGeneration0(
        width: json["width"],
        height: json["height"],
        logo: json["logo"] == null ? null : WallpaperLogoDrawer.fromJson(json["logo"]),
        background: json["background"] == null ? null : WallpaperBackgroundDrawer.fromJson(json["background"]),
    );

    Map<String, dynamic> toJson() => {
        "width": width,
        "height": height,
        "logo": logo?.toJson(),
        "background": background?.toJson(),
    };

    @override
    Future draw(CanvasRenderingContext2D ctx) async
    {
        // Make sure the canvas size is set
        ctx.canvas.width = width;
        ctx.canvas.height = height;

        // Make sure the default color of the canvas is clear
        ctx.fillRect(0, 0, width!, height!);

        // Draw the background
        await background!.draw(ctx);

        // Draw the logo
        await logo!.draw(ctx);
    } 
}