import 'dart:html';
import 'dart:convert';
import 'dart:math';

import 'Drawer/wallpaper_drawer.dart';
import 'Drawer/wallpaper_drawer_factory.dart';

const String canvasId = "#output";
const String textAreaId = "#input";
const String saveBtnId = "#save-btn";

const int numberOfConfigurations = 5;

void main() async {
    
    // Set first wallpaper
    await setFirstWallpaper();

    // Bind the UI
    bindUI();
}

Future<void> setFirstWallpaper () async {
  (WallpaperDrawer?, String?) drawer = await WallpaperDrawerFactory.getWallpaperDrawer(Random.secure().nextInt(numberOfConfigurations) + 1);
  setWallpaper(drawer.$1, drawer.$2);
}

void bindUI() {
    querySelector(textAreaId)?.onChange.listen((_) => updateWallpaper());
    querySelector(textAreaId)?.onInput.listen((_) => updateWallpaper());
    querySelector(saveBtnId)?.onClick.listen((_) => saveImage());
}

void saveImage() {
  print("Wallpaper Save");
  CanvasElement canvas = querySelector(canvasId) as CanvasElement;
  String dataUrl = canvas.toDataUrl('image/png');
  
  final anchor = AnchorElement(href: dataUrl)
    ..target = 'blank'
    ..download = 'canvas_image.png';

  anchor.click();
}

Future<void> updateWallpaper() async {
  print("Wallpaper Update");
  String compactJson = getJsonFromTextArea();
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

String getJsonFromTextArea() {
  TextAreaElement textArea = querySelector(textAreaId) as TextAreaElement;
  String jsonString = textArea.value!.trim();
  Map<String, dynamic> jsonData = jsonDecode(jsonString);
  return jsonEncode(jsonData);
}