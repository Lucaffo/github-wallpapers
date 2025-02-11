import 'dart:html';

/*
*   Wallpaper Drawer Abstract Class.
*   Each child implement a logic which draw something on the wallpaper canvas.
* 
*   Luca Raffo @ 04/02/2025
*/ 
abstract class WallpaperDrawer 
{
    Future draw(CanvasRenderingContext2D ctx);
}