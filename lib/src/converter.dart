import 'dart:io';

import 'rules.dart';
import 'node.dart';
import 'utils.dart' as util;

final _leadingNewLinesRegExp = new RegExp(r'^\n*');
final _trailingNewLinesRegExp = new RegExp(r'\n*$');

class Converter {}

class Rules {
  final _Options options = new _Options();
}

class _Options {
  static _Options _instance;
  _Options._();
  factory _Options() => _instance ?? new _Options._();

  static const List<String> headingStyles = const ['setext', 'atx'];
  static const List<String> hr = const ['* * *', '- - -', '_ _ _'];
  static const List<String> bulletListMarker = const ['*', '-', '_'];
  static const List<String> codeBlockStyle = const ['indented', 'fenced'];
  static const List<String> fence = const ['```', '~~~'];
  static const List<String> emDelimiter = const ['_', '*'];
  static const List<String> strongDelimiter = const ['**', '__'];
  static const List<String> linkStyle = const ['inlined', 'referenced'];
  static const List<String> linkReferenceStyle = const ['full', 'referenced'];
  static const String br = '  ';

  static blankReplacement(String content, Node node) {
    return node.isBlock ? '\n\n' : '';
  }

  static keepReplacement(String content, Node node) {
    return node.isBlock ? '\n\n' + node.outerHTML + '\n\n' : node.outerHTML;
  }

  static defaultReplacement(String content, Node node) {
    return node.isBlock ? '\n\n' + content + '\n\n' : content;
  }
}
