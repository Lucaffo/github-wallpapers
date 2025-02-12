import '../model/wallpaper.dart';
import 'wallpaper_factory.dart';
import 'package:http/http.dart' as http;

/*
* Get a wallpaper from an http request
* Luca Raffo @ 12/02/2025 
*/
class HTTPWallpaperFactory extends WallpaperFactory<Uri> {
 
  @override
  Future<Wallpaper?> getWallpaper(Uri param) async {
    final http.Response res = await http.get(param);
    if (res.statusCode != 200) return null;
    return _getWallpaper(res.body);
  }

  // Get a wallpaper from a json string
  Future<Wallpaper?> _getWallpaper(String jsonContent)
  {
    try{
      return Future.value(Wallpaper.fromRawJson(jsonContent)); 
    }
    // ignore: empty_catches
    on Exception {}
    return Future.value(null);
  }
}