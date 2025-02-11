import 'dart:convert';

import 'package:http/http.dart' as http;

import 'wallpaper_drawer.dart';
import 'wallpaper_drawer_generation_0.dart';

/*
*   Wallpaper Drawer Factory Class.
*   Implements the logic about the creation of a wallpaper drawer.
* 
*   Luca Raffo @ 04/02/2025
*/ 
class WallpaperDrawerFactory 
{
    // Get a default wallpaper drawer from the wallpaper configurations
    static Future<(WallpaperDrawer?, String?)> getWallpaperDrawer(int index) async
    {
        return await getDrawerHttp("https://lucaffo.github.io/github-wallpapers/static/wallpapers/wallpaper_${index.toString().padLeft(2, '0')}.json");
    }

    // Get the drawer for the wallpaper json via http 
    static Future<(WallpaperDrawer?, String?)> getDrawerHttp(String url) async
    {
        // Read the json from the file and map the content
        String? jsonContent = await _jsonFromUrl(url);
        if (jsonContent == null) return (null, null);
        
        return getDrawerFromJson(jsonContent);
    }

    // Get the drawer for the wallpaper from a json
    // It returns the drawer instance and the version
    static Future<(WallpaperDrawer?, String?)> getDrawerFromJson(String? jsonContent) async
    {
        if (jsonContent == null) return (null, null);

        try {
            final Map<String, dynamic> map = json.decode(jsonContent);
            switch(map["version"])
            {
                case 0:
                { 
                  WallpaperDrawerGeneration0 gen0 = WallpaperDrawerGeneration0.fromJson(map["wallpaper"]);
                  return (gen0, jsonContent);
                }
            }
        } 
        on Exception catch(e){
            print("$e\nError during wallpaper json parsing. Make sure the format is correct.\n$jsonContent");
            return (null, null);
        }

        return (null, null);
    } 

    // Get a json from the url
    static Future<String?> _jsonFromUrl(String jsonPath) async
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