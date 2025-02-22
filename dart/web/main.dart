import 'package:dart/controllers/github_wallpapers_app.dart';

final GithubWallpapersApp app = new GithubWallpapersApp();

void main() async {
  await app.setFirstWallpaper();
  app.bindUI();
}