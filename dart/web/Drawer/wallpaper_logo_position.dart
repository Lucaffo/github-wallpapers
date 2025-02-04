import 'dart:math';

/*
*   Wallpaper Logo Position Class.
*   This is responsible for the relative position of the logo on the canvas.
*   Make sure the coordinates are clamped between 0..1.
*
*   Luca Raffo @ 04/02/2025
*/ 
class WallpaperLogoPosition
{
   double x;
   double y;
   
   WallpaperLogoPosition(this.x, this.y)
   {
      x = min(max(x, 0), 1);
      y = min(max(y, 0), 1);
   }
}
