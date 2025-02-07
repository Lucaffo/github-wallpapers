import 'image_urls.dart';
import 'image_url.dart';

final class ImageCollections {

    static final ImageUrls logos = ImageUrls("logos", "https://lucaffo.github.io/github-wallpapers/static/logos/paths.json");
    static final ImageUrls octocats = ImageUrls("octocats", "https://lucaffo.github.io/github-wallpapers/static/octocats/paths.json");

    static Future<ImageUrl?> getByTypeAndName(String? type, String? name) async
    {
        switch(type!.toLowerCase())
        {
            case "logos" :
            {
              await logos.readAllUrls();
              return logos.search(name);
            } 
            case "octocats" : 
            {
              await octocats.readAllUrls();
              return octocats.search(name);
            }
        }

        return null;
    }

    static Future<ImageUrl?> getRandomLogo() async
    {
        await logos.readAllUrls();
        return logos.getRandomUrl();
    }
}