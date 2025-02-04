import 'dart:html';
import '../Images/image_url.dart';
import 'wallpaper_drawer.dart';

/*
*   Wallpaper Logo Background Class.
*   This is responsible for drawing the background of the canvas.
*
*   Luca Raffo @ 04/02/2025
*/ 
class WallpaperBackgroundDrawer extends WallpaperDrawer
{
    String color;
    ImageUrl? path;

    WallpaperBackgroundDrawer(this.color, this.path);
    
    @override
    Future draw(CanvasRenderingContext2D ctx) async
    {
        ImageElement background = ImageElement();

        if (path == null)
        {
            background.width = ctx.canvas.width!;
            background.height = ctx.canvas.height!;
            background.style.backgroundColor = color;
        }else
        {
            background.src = path?.getFullPath();
            await background.onLoad.first; 
        }

        ctx.drawImageScaled(background, 0, 0, ctx.canvas.width!, ctx.canvas.height!);
    }
}
