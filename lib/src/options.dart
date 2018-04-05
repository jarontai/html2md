const List<String> headingStyles = const ['setext', 'atx'];
const List<String> hr = const ['* * *', '- - -', '_ _ _'];
const List<String> bulletListMarker = const ['*', '-', '_'];
const List<String> codeBlockStyle = const ['indented', 'fenced'];
const List<String> fence = const ['```', '~~~'];
const List<String> emDelimiter = const ['_', '*'];
const List<String> strongDelimiter = const ['**', '__'];
const List<String> linkStyle = const ['inlined', 'referenced'];
const List<String> linkReferenceStyle = const ['full', 'collapsed', 'shortcut'];
const String br = '  ';

final options = <String, String>{
  'headingStyle': headingStyles[0],
  'hr': hr[0],
  'bulletListMarker': bulletListMarker[0],
  'codeBlockStyle': codeBlockStyle[0],
  'fence': fence[0],
  'emDelimiter': emDelimiter[0],
  'strongDelimiter': strongDelimiter[0],
  'linkStyle': linkStyle[0],
  'linkReferenceStyle': linkReferenceStyle[0],
  'br': br,
};