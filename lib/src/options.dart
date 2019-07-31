final _styleMap = <String, _StyleOption>{
  'headingStyle': new _StyleOption(['setext', 'atx']),
  'hr': new _StyleOption(['* * *', '- - -', '_ _ _']),
  'bulletListMarker': new _StyleOption(['*', '-', '_']),
  'codeBlockStyle': new _StyleOption(['indented', 'fenced']),
  'fence': new _StyleOption(['```', '~~~']),
  'emDelimiter': new _StyleOption(['_', '*']),
  'strongDelimiter': new _StyleOption(['**', '__']),
  'linkStyle': new _StyleOption(['inlined', 'referenced']),
  'linkReferenceStyle': new _StyleOption(['full', 'collapsed', 'shortcut']),
  'br': new _StyleOption(['  ']),
};

List<String> get removeTags => ['noscript'];

String getStyleOption(String name) => _styleMap[name]?.style ?? '';

updateStyleOptions(Map<String, String> customOptions) {
  if (customOptions != null && customOptions.isNotEmpty) {
    var names = _styleMap.keys;
    customOptions.forEach((key, val) {
      if (names.contains(key)) {
        _styleMap[key].style = val;
      }
    });
  }
}

class _StyleOption {
  int defaultIndex;
  final List<String> options;
  _StyleOption(this.options, {this.defaultIndex = 0});
  String get style => options[defaultIndex];
  set style(String style) {
    var index = options.indexOf(style);
    // Ignore invalid option
    if (index > -1) {
      defaultIndex = index;
    }
  }
}
