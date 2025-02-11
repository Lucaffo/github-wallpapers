import 'dart:html';
import 'dart:convert';

import 'wallpaper_drawer.dart';
import 'wallpaper_logo_position.dart';

import '../images/image_url.dart';
import '../images/image_collections.dart';

import '../extensions/canvas_context_ext.dart';

/*
*   Wallpaper Logo Drawer Class.
*   This is responsible for drawing a logo on the canvas.
*
*   Luca Raffo @ 04/02/2025
*/ 
class WallpaperLogoDrawer extends WallpaperDrawer
{
    String? type;
    String? name;
    String? blend;
    double size;
    WallpaperLogoPosition? position;
    String? color;

    WallpaperLogoDrawer({
        this.type,
        this.name,
        this.blend,
        this.size = 1,
        this.position,
        this.color,
    });

    factory WallpaperLogoDrawer.fromRawJson(String str) => WallpaperLogoDrawer.fromJson(json.decode(str));

    factory WallpaperLogoDrawer.fromJson(Map<String, dynamic> json) => WallpaperLogoDrawer (
        type: json["type"],
        name: json["name"],
        blend: json["blend"],
        size: json["size"]?.toDouble(),
        position: json["position"] == null ? null : WallpaperLogoPosition.fromJson(json["position"]),
        color: json["color"],
    );

    String toRawJson() => json.encode(toJson());

    Map<String, dynamic> toJson() => {
        "type": type,
        "name": name,
        "blend" : blend,
        "size": size,
        "position": position?.toJson(),
        "color": color,
    };
    
    @override
    Future draw(CanvasRenderingContext2D ctx) async
    {
        if (type == null || type!.isEmpty) return;
        if (name == null || name!.isEmpty) return; 

        ImageUrl? logoSrc = await ImageCollections.getLogoByTypeAndNamea(type, name);
        if (logoSrc == null) return;

        ImageElement logo = ImageElement();
        logo.src = logoSrc.getFullPath();
        logo.crossOrigin = 'anonymous';
        await logo.onLoad.first; 

        int logoWidth = (logo.width! * size).toInt();
        int logoHeight = (logo.height! * size).toInt();
        
        CanvasElement logoCanvas = CanvasElement(width: logo.width, height: logo.height);
        CanvasRenderingContext2D logoCtx = logoCanvas.context2D;

        logoCtx.drawImage(logo, 0, 0);
        logoCtx.globalCompositeOperation = blend != null ? blend! : 'multiply';
        logoCtx.setFillStyleAndAlpha(color);
        logoCtx.fillRect(0, 0, logo.width!.toDouble(), logo.height!.toDouble());
        logoCtx.globalCompositeOperation = "destination-atop"; // restore transparency
        logoCtx.drawImage(logo, 0, 0);

        num logoPosX = position?.x != null ? position!.x : 0.5;
        num logoPosY = position?.y != null ? position!.y : 0.5;

        num centerX = ((ctx.canvas.width! * logoPosX) - logoWidth / 2);
        num centerY = ((ctx.canvas.height! * logoPosY) - logoHeight / 2);

        ctx.drawImageScaled(logoCanvas, centerX, centerY, logoWidth, logoHeight);
    }
}