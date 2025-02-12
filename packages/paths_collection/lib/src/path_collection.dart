import 'dart:math';
import 'dart:convert';
import 'path_url.dart';
import 'package:http/http.dart' as http;

/*
*  Path Collection class.
*  Manage a collection of Path Url.
*  
*  Luca Raffo @ 12/02/2025
*/
class PathCollection {

  final String _jsonPath;
  final String _name;
  final List<PathUrl> _urls = [];
  bool _loaded = false;

  PathCollection(this._name, this._jsonPath);

  // Read all the urls from a json path
  // Write all the results into the @urls
  Future readAllUrls() async {
    if (_loaded) return;
    await _readFromUrl(_jsonPath);
  }

  // From a json path, read and populate all the urls
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
      paths.forEach((v) => {print(v), _urls.add(PathUrl(v))});
      _loaded = true;
      print("Added all the urls to $_name");
    }
  }

  // Get a random url form the urls
  PathUrl? getRandomUrl() {
    if (_urls.isEmpty) return null;
    var randomIndex = Random().nextInt(_urls.length);
    return _urls.elementAt(randomIndex);
  }

  // Get a url using an index
  PathUrl? getUrlAt(int index) {
    if (index < 0 || index >= _urls.length) return null;
    return _urls.elementAt(index);
  }

  // Get the number of urls
  int getUrlsNumber() {
    return _urls.length;
  }

  // Search the first path with name
  PathUrl? search(String? name) {
    if (name != null) {
      for (int i = 0; i < _urls.length; i++) {
        if (_urls[i].getFileName(false)!.contains(name)) {
          return _urls[i];
        }
      }
    }

    return null;
  }

  // Check if it's loaded one time
  bool isLoaded() => _loaded;
}
