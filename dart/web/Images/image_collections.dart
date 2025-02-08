import 'dart:math';

import 'image_urls.dart';
import 'image_url.dart';

final class ImageCollections {

    static final ImageUrls logos = ImageUrls("logos", "https://lucaffo.github.io/github-wallpapers/static/logos/paths.json");
    static final ImageUrls octocats = ImageUrls("octocats", "https://lucaffo.github.io/github-wallpapers/static/octocats/paths.json");
    static final ImageUrls backgrounds = ImageUrls("octocats", "https://lucaffo.github.io/github-wallpapers/static/backgrounds/paths.json");

    static Future<ImageUrl?> getLogoByTypeAndNamea(String? type, String? name) async {

        if (type == null || name == null) return null;

        type = type.toLowerCase();
        name = name.toLowerCase();

        if (type.contains("octocat")) {
          await octocats.readAllUrls();
          return octocats.search(name);
        }

        if (type.contains("logo")) {
          await logos.readAllUrls();
          return logos.search(name);
        }

        return null;
    }
    
    static Future<ImageUrl?> getBackgroundByName(String? name) async {

        if (name == null) return null;
        name = name.toLowerCase();

        await backgrounds.readAllUrls();
        return backgrounds.search(name);
    } 

    static Future<ImageUrl?> getRandomLogo() async
    {
        await logos.readAllUrls();
        return logos.getRandomUrl();
    }

    static Future<ImageUrl?> getRandomOctocat() async
    {
        await octocats.readAllUrls();
        return octocats.getRandomUrl();
    }

    static String generateHexColor() {
      Random random = Random();
      String colore = '#';
      for (int i = 0; i < 6; i++) {
        colore += random.nextInt(16).toRadixString(16).padLeft(1, '0').toUpperCase();
      }
      return colore;
    }
}