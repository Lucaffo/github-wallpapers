import 'dart:html';
import 'wallpaper_drawer.dart';
import 'wallpaper_logo_position.dart';
import '../Images/image_url.dart';

/*
*   Wallpaper Logo Drawer Class.
*   This is responsible for drawing a logo on the canvas.
*
*   Luca Raffo @ 04/02/2025
*/ 
class WallpaperLogoDrawer extends WallpaperDrawer
{
    double size;
    WallpaperLogoPosition position;
    String color;
    ImageUrl path;

    WallpaperLogoDrawer(this.size, this.position, this.color, this.path);
    
    @override
    Future draw(CanvasRenderingContext2D ctx) async
    {
        ImageElement logo = ImageElement();

        logo.src = path.getFullPath();
        await logo.onLoad.first; 

        logo.style.color = color;

        int logoWidth = (logo.width! * size).toInt();
        int logoHeight = (logo.height! * size).toInt();

        num centerX = ((ctx.canvas.width! * position.x) - logoWidth / 2);
        num centerY = ((ctx.canvas.height! * position.y) - logoHeight / 2);

        ctx.drawImageScaled(logo, centerX, centerY, logoWidth, logoHeight);
    }
}
