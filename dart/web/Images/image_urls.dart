import 'dart:convert';
import 'dart:math';
import 'image_url.dart';
import 'package:http/http.dart' as http;

/*
*  Image Urls class.
* 
*  Manage multiple Image Url. Conversion from a json file.
*  
*  Luca Raffo @ 04/02/2025
*/
class ImageUrls {
  final String _jsonPath;
  final String _name;
  final List<ImageUrl> _urls = [];
  bool _loaded = false;

  ImageUrls(this._name, this._jsonPath);

  // Read all the urls from a json path
  // Write all the results into the @urls
  Future readAllUrls() async {
    if (_loaded) return;
    await _readFromUrl(_jsonPath);
  }

  Future _readFromUrl(String jsonPath) async {
    Uri uri = Uri.parse(jsonPath);
    final http.Response res = await http.get(uri);
    if (res.statusCode == 200) {
      _populateUrlsFromJson(res.body);
    }
  }

  // Populate the urls array from a json content
  void _populateUrlsFromJson(String jsonContent) {
    final Map<String, dynamic> map = json.decode(jsonContent);

    var paths = map["paths"];
    print(paths);

    if (paths != null) {
      _urls.clear();
      paths.forEach((v) => {print(v), _urls.add(ImageUrl(v))});
      _loaded = true;
      print("Added all the urls to $_name");
    }
  }

  // Get a random url form the urls
  ImageUrl? getRandomUrl() {
    if (_urls.isEmpty) return null;
    var randomIndex = Random().nextInt(_urls.length);
    return _urls.elementAt(randomIndex);
  }

  // Get a url using an index
  ImageUrl? getUrlAt(int index) {
    if (index < 0 || index >= _urls.length) return null;
    return _urls.elementAt(index);
  }

  // Get the number of urls
  int getUrlsNumber() {
    return _urls.length;
  }

  // Search the first logo with than name
  ImageUrl? search(String? logo) {
    if (logo != null) {
      for (int i = 0; i < _urls.length; i++) {
        if (_urls[i].getFileName(false)!.contains(logo)) {
          return _urls[i];
        }
      }
    }

    // Return a random url else
    return getRandomUrl();
  }

  // Check if it's loaded one time
  bool isLoaded() => _loaded;
}
