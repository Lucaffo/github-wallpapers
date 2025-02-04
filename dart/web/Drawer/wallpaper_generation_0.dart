import 'dart:html';

import '../Images/image_url.dart';
import '../Images/image_urls.dart';

import 'wallpaper_background_drawer.dart';
import 'wallpaper_drawer.dart';
import 'wallpaper_logo_drawer.dart';
import 'wallpaper_logo_position.dart';

class WallpaperGeneration0 extends WallpaperDrawer
{
    static final ImageUrls logos = ImageUrls("logos", "https://lucaffo.github.io/github-wallpapers/static/logos/paths.json");
    static final ImageUrls octocats = ImageUrls("octocats", "https://lucaffo.github.io/github-wallpapers/static/octocats/paths.json");

    final Map<String, dynamic> _map;
    
    int? _width;
    int? _height;
    WallpaperLogoDrawer? _logoDrawer;
    WallpaperBackgroundDrawer? _backgroundDrawer;

    WallpaperGeneration0(this._map);

    @override
    Future draw(CanvasRenderingContext2D ctx) async
    {
        // Read the logo and octocats collections
        await logos.readAllUrls();
        await octocats.readAllUrls();

        // Configure the wallpaper from the json
        createDrawersFromJson(_map);

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

    void createDrawersFromJson(Map<String, dynamic> map) 
    {
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

                ImageUrl? logoUrl;

                var type = logo["type"].toString().toLowerCase();
                if (type == "octocat")
                {
                    logoUrl = octocats.search(logo["src"]);
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
                ImageUrl? imgUrlSrc;

                if(src != null)
                {
                    imgUrlSrc = ImageUrl(src);
                }
                
                _backgroundDrawer = WallpaperBackgroundDrawer(color, imgUrlSrc);
            }
        }
    } 
}