import 'dart:math';
import 'dart:convert';
import 'path_url.dart';
import 'dart:html';

import 'package:worker_database/worker_database.dart';

/*
*  Path Collection class.
*  Manage a collection of Path Url.
*  
*  Luca Raffo @ 12/02/2025
*/
class PathCollection {

  final String _jsonPath;
  final List<PathUrl> _urls = [];
  
  static final WorkerDatabase pathDB = WorkerDatabase<String, String>("PathsDB", "PathsStore");

  PathCollection(this._jsonPath);

  // Read all the urls from a json path
  // Write all the results into the @urls
  Future readAllUrls() async {
    await _readFromUrl(_jsonPath);
  }

  // From a json path, read and populate all the urls
  Future _readFromUrl(String jsonPath) async {
    
    // Try to fetch the json from the pathDB cache, else do an http request
    String? resCache = await pathDB.tryFetch(jsonPath);
    if(resCache == null){
      final HttpRequest res = await HttpRequest.request(jsonPath);
      if (res.status == 200) {
        resCache = res.response;
        await pathDB.tryPut(jsonPath, resCache);
      }
    }

    // Populat the urls from the json
    if(resCache != null){
      _populateUrlsFromJson(resCache);
    }
  }

  // Populate the urls array from a json content
  void _populateUrlsFromJson(String jsonContent) {
    final Map<String, dynamic> map = json.decode(jsonContent);

    var paths = map["paths"];

    if (paths != null) {
      _urls.clear();
      paths.forEach((v) => {_urls.add(PathUrl(v))});
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
}
