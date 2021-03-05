final _styleMap = <String, _StyleOption>{
  'headingStyle': _StyleOption(['setext', 'atx']),
  'hr': _StyleOption(['* * *', '- - -', '_ _ _']),
  'bulletListMarker': _StyleOption(['*', '-', '_']),
  'codeBlockStyle': _StyleOption(['indented', 'fenced']),
  'fence': _StyleOption(['```', '~~~']),
  'emDelimiter': _StyleOption(['_', '*']),
  'strongDelimiter': _StyleOption(['**', '__']),
  'linkStyle': _StyleOption(['inlined', 'referenced']),
  'linkReferenceStyle': _StyleOption(['full', 'collapsed', 'shortcut']),
  'br': _StyleOption(['  ']),
};

List<String> get removeTags => ['noscript'];

String getStyleOption(String name) => _styleMap[name]?.style ?? '';

void updateStyleOptions(Map<String, String>? customOptions) {
  if (customOptions != null && customOptions.isNotEmpty) {
    var names = _styleMap.keys;
    customOptions.forEach((key, val) {
      if (names.contains(key)) {
        _styleMap[key]!.style = val;
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
