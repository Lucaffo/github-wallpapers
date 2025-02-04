import 'dart:html';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'wallpaper_drawer.dart';
import 'wallpaper_generation_0.dart';

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

    Wallpaper(this.jsonPath);

    @override
    Future draw(CanvasRenderingContext2D ctx) async
    {
        // Read the json from the file and map the content
        String? jsonContent = await _jsonFromUrl(jsonPath);
        if (jsonContent == null) return;
        final Map<String, dynamic> map = json.decode(jsonContent);

        // Get the wallpaper json version
        try
        {
            _version = map["version"];
        } on Exception catch(e)
        {
            print("Error during wallpaper json parsing. Make sure the format is correct.\n${jsonContent}");
            print (e);
            return;
        }

        // Draw based on the version
        switch(_version)
        {
            case 0: WallpaperGeneration0(map).draw(ctx);
        }
    }

    // Get a json from the url
    Future<String?> _jsonFromUrl(String jsonPath) async
    {
        Uri uri = Uri.parse(jsonPath);
        final http.Response res = await http.get(uri);
        if(res.statusCode == 200)
        {
            return res.body;
        }

        return null;
    }
}
