const List<String> _headingStyles = const ['setext', 'atx'];
const List<String> _hr = const ['* * *', '- - -', '_ _ _'];
const List<String> _bulletListMarker = const ['*', '-', '_'];
const List<String> _codeBlockStyle = const ['indented', 'fenced'];
const List<String> _fence = const ['```', '~~~'];
const List<String> _emDelimiter = const ['_', '*'];
const List<String> _strongDelimiter = const ['**', '__'];
const List<String> _linkStyle = const ['inlined', 'referenced'];
const List<String> _linkReferenceStyle = const ['full', 'collapsed', 'shortcut'];
const String _br = '  ';

final _styleOptions = <String, String>{
  'headingStyle': _headingStyles[0],
  'hr': _hr[0],
  'bulletListMarker': _bulletListMarker[0],
  'codeBlockStyle': _codeBlockStyle[0],
  'fence': _fence[0],
  'emDelimiter': _emDelimiter[0],
  'strongDelimiter': _strongDelimiter[0],
  'linkStyle': _linkStyle[0],
  'linkReferenceStyle': _linkReferenceStyle[0],
  'br': _br,
};

updateStyleOptions(Map<String, String> customOptions) {
  if (customOptions != null && customOptions.isNotEmpty) {
    _styleOptions.addAll(customOptions);
  }
}

Map<String, String> get styleOptions => _styleOptions;

List<String> get removeTags => ['noscript'];