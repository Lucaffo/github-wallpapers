import 'dart:html';
import 'dart:convert';
import 'dart:math';

import 'package:wallpaper/wallpaper.dart';
import 'package:wallpaper_generator/wallpaper_generator.dart';

import 'package:image/image.dart';

const String canvasId = "#output";
const String textAreaId = "#input";
const String saveBtnId = "#save-btn";

const int numberOfConfigurations = 7;

void main() async {
    
    // Set first wallpaper
    await setFirstWallpaper();

    // Bind the UI
    bindUI();
}

Future<void> setFirstWallpaper () async {
  HTTPWallpaperFactory httpWallpaperFactory = HTTPWallpaperFactory();
  Wallpaper? wallpaper = await httpWallpaperFactory.getWallpaper(getRandomInitialConfiguration());
  setWallpaper(wallpaper);
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
  Wallpaper? wallpaper = Wallpaper.fromRawJson(compactJson);
  setWallpaper(wallpaper);
}

void setWallpaper(Wallpaper? wallpaper) {
  if (wallpaper == null) return;
  setJsonInTextArea(wallpaper.toRawJson());
  updateCanvas(wallpaper);
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

Future updateCanvas(Wallpaper? wallpaper) async {
  if (wallpaper == null) return;

  Image? image = await WallpaperGenerator.generateWallpaper(wallpaper);
  if (image == null) return;

  CanvasElement canvas = querySelector(canvasId) as CanvasElement;
  canvas.width = image.width;
  canvas.height = image.height;
  CanvasRenderingContext2D ctx = canvas.context2D;

  var imageData = ctx.createImageData(image.width, image.height);
  var imageBytes = image.getBytes();

  print("Canvas dimensions: ${canvas.width}x${canvas.height}");
  print("Image dimensions: ${image.width}x${image.height}");
  print("imageData.data.length: ${imageData.data.length}");
  print("imageBytes.length: ${imageBytes.length}");
  print("Final image dimensions: ${imageData.width}x${imageData.height}");
  
  imageData.data.setRange(0, imageData.data.length, imageBytes);
  ctx.putImageData(imageData, 0, 0);
}

String getJsonFromTextArea() {
  TextAreaElement textArea = querySelector(textAreaId) as TextAreaElement;
  String jsonString = textArea.value!.trim();
  Map<String, dynamic> jsonData = jsonDecode(jsonString);
  return jsonEncode(jsonData);
}

Uri getRandomInitialConfiguration()
{
  int index = Random.secure().nextInt(numberOfConfigurations) + 1;
  return Uri.parse("https://lucaffo.github.io/github-wallpapers/static/wallpapers/wallpaper_${index.toString().padLeft(2, '0')}.json");
}