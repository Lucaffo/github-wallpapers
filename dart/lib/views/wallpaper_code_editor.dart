import 'dart:convert';

import 'package:code_mirror/code_mirror.dart';
import 'package:wallpaper/wallpaper.dart';

class WallpaperCodeEditor {

  String editorName;
  late CodeMirrorEditor codeEditor;
  
  WallpaperCodeEditor(this.editorName){
    codeEditor = CodeMirrorEditor(editorName);
  }

  // Set the wallpaper as json in the code editor
  void setWallpaper(Wallpaper? wallpaper) {
    if (wallpaper == null) return;
    String rawjson = wallpaper.toRawJson();
    Map<String, dynamic>? map = json.decoder.convert(rawjson);
    if (map == null) return;
    JsonEncoder encoder = JsonEncoder.withIndent('  ');
    String prettyprint = encoder.convert(map);
    codeEditor.setValue(prettyprint);
  }

  // Get a constructed wallpaper from the wallpaper code editor
  Wallpaper? getWallpaper() {
    String? compactJson = codeEditor.getValue();
    if (compactJson == null) return null;
    Wallpaper? wallpaper = Wallpaper.fromRawJson(compactJson);
    return wallpaper;
  }

  // Listen to on change event
  void onChange(Function callback){
    codeEditor.onChange(callback);
  }
}