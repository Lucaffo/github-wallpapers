import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'image_url.dart';

/*
*  Image Urls class. 
*  Manage multiple Image Url. Conversion from a json file.
*  
*  Luca Raffo @ 04/02/2025
*/
class ImageUrls 
{
    final String _jsonPath;
    final List<ImageUrl> _urls = [];
    
    ImageUrls(this._jsonPath)
    {
        ReadAllUrls(_jsonPath);
    }
    
    // Read all the urls from a json path
    // Write all the results into the @urls
    void ReadAllUrls(String jsonPath)
    {
        String jsonString = File(jsonPath).readAsStringSync();
        final Map<String, dynamic> map = json.decode(jsonString);
        
        var paths = map["paths"];
        if(paths != null)
        { 
            _urls.clear();
            paths.forEach((v) => 
            {
                _urls.add(ImageUrl(v))
            });
        }
    }

    // Get a random url form the urls
    ImageUrl GetRandomUrl()
    {
        var randomIndex = Random().nextInt(_urls.length);
        return _urls.elementAt(randomIndex);
    }

    // Get a url using an index
    ImageUrl? GetUrlAt(int index)
    {
        if (index < 0 || index >= _urls.length) return null;
        return _urls.elementAt(index);
    }

    // Get the number of urls
    int GetUrlsNumber()
    {
        return _urls.length;
    }
}