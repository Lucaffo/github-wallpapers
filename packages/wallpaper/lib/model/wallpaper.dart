import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart';

import 'package:wallpaper/model/wallpaper_background.dart';
import 'package:wallpaper/model/wallpaper_logo.dart';
import 'package:wallpaper/generator/wallpaper_generator.dart';

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

    // Create a wallpaper model from an url
    static Future<Wallpaper?> fromUrl(String url) async {
      return await fromUri(Uri.parse(url));
    }

    // Create a wallpaper model form an uri
    static Future<Wallpaper?> fromUri(Uri param) async {
      final Response res = await get(param);
      if (res.statusCode != 200) return null;
      return Wallpaper.fromRawJson(res.body);
    }

    // Generate a wallpaper from the model into a byte array
    // this format is friendly to postMessage despite BitmapImage or OffscreenCanvas
    // cause for some reason in dart this object are set to null after despite they
    // are "transferable"... idk. Bruteforcing to Uint8List works like a charm.
    Future<Uint8List?> generate({Function(String)? updatingFunction}) async {

      // Generate the wallpaper
      Uint8List? imageBytes = await WallpaperGenerator.generateWallpaper(this, updatingFunction);
      if (imageBytes == null) {
        print("Generated image is null, there it was an error in the wallpaper generation.");
        return null;
      }

      return imageBytes;
    }
}
