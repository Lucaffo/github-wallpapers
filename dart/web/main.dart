import 'dart:html';
import 'dart:convert';

import 'Drawer/wallpaper_drawer.dart';
import 'Drawer/wallpaper_drawer_factory.dart';

const String canvasId = "#output";
const String textAreaId = "#input";

void main() async {
    
    // Set first wallpaper
    await setFirstWallpaper();

    // Bind the UI
    bindUI();
}

Future<void> setFirstWallpaper () async {
  (WallpaperDrawer?, String?) drawer = await WallpaperDrawerFactory.getWallpaperDrawer(1);
  setWallpaper(drawer.$1, drawer.$2);
}

void bindUI() {
    querySelector("#input")?.onChange.listen((_) => updateWallpaper());
    querySelector("#input")?.onInput.listen((_) => updateWallpaper());
    querySelector("#toggleTextArea")?.onClick.listen((_) => toggleTextArea());
}

void toggleTextArea(){
  bool? state = querySelector(textAreaId)?.hidden;
  querySelector(textAreaId)?.hidden = state == null ? false : !state;
}

Future<void> updateWallpaper() async {
  print("Wallpaper Update");
  TextAreaElement textArea = querySelector(textAreaId) as TextAreaElement;

  String jsonString = textArea.value!.trim();
  Map<String, dynamic> jsonData = jsonDecode(jsonString);
  String compactJson = jsonEncode(jsonData);

  (WallpaperDrawer?, String?) drawer = await WallpaperDrawerFactory.getDrawerFromJson(compactJson);
  updateCanvas(drawer.$1);
}

void setWallpaper(WallpaperDrawer? drawer, String? jsonString) {
  if (drawer == null || jsonString == null) return;
  setJsonInTextArea(jsonString);
  updateCanvas(drawer);
}

void setJsonInTextArea(String? jsonString) {
  if (jsonString == null) return;
  Map<String, dynamic>? map = json.decoder.convert(jsonString);
  if (map == null) return;
  TextAreaElement textArea = querySelector(textAreaId) as TextAreaElement;
  JsonEncoder encoder = JsonEncoder.withIndent('  ');
  String prettyprint = encoder.convert(map);
  textArea.text = prettyprint;
}

void updateCanvas(WallpaperDrawer? drawer) {
  CanvasElement canvas = querySelector(canvasId) as CanvasElement;
  CanvasRenderingContext2D ctx = canvas.context2D;
  drawer?.draw(ctx);
}