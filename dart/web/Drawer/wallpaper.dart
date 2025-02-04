import 'dart:html';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Images/image_url.dart';
import 'wallpaper_drawer.dart';
import 'wallpaper_logo_drawer.dart';
import 'wallpaper_logo_position.dart';
import 'wallpaper_background_drawer.dart';

/*
*   Wallpaper Drawer.
*   Draw the entire wallpaper.
*   
*   Luca Raffo @ 04/02/2025
*/ 
class Wallpaper extends WallpaperDrawer
{
    String jsonPath;

    int? _version;
    int? _width;
    int? _height;
    WallpaperLogoDrawer? _logoDrawer;
    WallpaperBackgroundDrawer? _backgroundDrawer;

    Wallpaper(this.jsonPath);

    @override
    Future draw(CanvasRenderingContext2D ctx) async
    {
        // Read the wallpaper json configuration
        bool res = await _readFromUrl(jsonPath);
        if (res == false) 
        {
            return;
        }

        // Make sure the canvas size is set
        ctx.canvas.width = _width;
        ctx.canvas.height = _height;

        // Make sure the default color of the canvas is clear
        ctx.fillStyle = "clear";
        ctx.fillRect(0, 0, _width!, _height!);

        // Draw the background
        await _backgroundDrawer?.draw(ctx);

        // Draw the logo
        await _logoDrawer?.draw(ctx);
    }
    
    Future<bool> _readFromUrl(String jsonPath) async
    {
        Uri uri = Uri.parse(jsonPath);
        final http.Response res = await http.get(uri);
        if(res.statusCode == 200)
        {
            try
            {
                configureWallpaperFromJson(res.body);
            } on Exception catch(e)
            {
                print("Error during wallpaper json parsing. Make sure the format is correct.\n${res.body}");
                print (e);
                return false;
            }
            return true;
        }
        
        print("Unable to read wallpaper json configuration \"$jsonPath\"");
        return false;
    }
    
    void configureWallpaperFromJson(String jsonContent) 
    {
        final Map<String, dynamic> map = json.decode(jsonContent);
        
        _version = map["version"];
        var wallpaper = map["wallpaper"];
        if (wallpaper != null)
        {
            _width = wallpaper["width"];
            _height = wallpaper["height"];
            var logo = wallpaper["logo"];
            if (logo != null)
            {
                var size = logo["size"];
                var position = logo["position"];
                double x = 0;
                double y = 0;

                if (position != null)
                {
                    x = position["x"];
                    y = position["y"];
                }

                var color = logo["color"];
                var src = logo["src"];

                _logoDrawer = WallpaperLogoDrawer(size, WallpaperLogoPosition(x, y), color, ImageUrl(src));
            }

            var background = wallpaper["background"];
            if (background != null)
            {
                var color = background["color"];
                var src = background["src"];
                var imgUrlSrc = null;
                if(src != null)
                {
                    imgUrlSrc = ImageUrl(src);
                }
                
                _backgroundDrawer = WallpaperBackgroundDrawer(color, imgUrlSrc);
            }
        }
    } 
}