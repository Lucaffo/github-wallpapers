import 'dart:js';
import 'dart:html';

class CodeMirrorEditor {
  late JsObject _instance;

  bool _avoidChange = false;

  /// Default CodeMirror options
  static final Map<String, dynamic> _defaultOptions = {
    'mode': 'javascript',
    'theme': 'material-darker',
    'lineNumbers': true,
    'indentWithTabs' : true,
    'matchBrackets' : true
  };

  CodeMirrorEditor(String elementId) {
    var element = document.querySelector(elementId);
    if (element == null) {
      throw ArgumentError("Element cannot be found at ID '$elementId'");
    }

    _instance = JsObject(context['CodeMirror'], [element, JsObject.jsify(_defaultOptions)]);
  }

  /// Listen for content changes.
  void onChange(Function callback) {
    final onChangeCallback = JsFunction.withThis((window, arg1, arg2) {
      if (_avoidChange) {_avoidChange = false; return; }
      callback();
    });
    
    _instance.callMethod('on', ['change', onChangeCallback]);
  }

  /// Set the content of the editor.
  void setValue(String? content) {
    _avoidChange = true;
    _instance.callMethod('setValue', [content]);
  }

  /// Get the current content of the editor.
  String? getValue() {
    return _instance.callMethod('getValue', []);
  }
}
