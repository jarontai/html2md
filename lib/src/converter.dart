import 'dart:io';

import 'rules.dart';
import 'node.dart';
import 'utils.dart' as util;

final _leadingNewLinesRegExp = new RegExp(r'^\n*');
final _trailingNewLinesRegExp = new RegExp(r'\n*$');

class Converter {
  String convert(String html) {
    if (html == null || html.isEmpty) {
      return '';
    }
  }

  String process(Node parentNode) {
    var result = '';
    for (var node in parentNode.childNodes()) {
      var replacement = '';
      if (node.nodeType == 3) {
        replacement = node.isCode ? node.textContent : escape(node.textContent);
      } else if (node.nodeType == 1) {
        replacement = _replacementForNode(node);
      }
      // TODO: join
      result = _join(result, replacement);
    }
    return result;
  }

  // Determines the new lines between the current output and the replacement
  String _separatingNewlines(String output, String replacement) {
    var newlines = [
      _trailingNewLinesRegExp.stringMatch(output),
      _leadingNewLinesRegExp.stringMatch(replacement),
    ];
    newlines.sort((a, b) => a.compareTo(b));

    var maxNewlines = newlines.last;
    return maxNewlines.length < 2 ? maxNewlines : '\n\n';
  }

  _join(string1, string2) {
    return '';
  }

  String _replacementForNode(Node node) {
    // var rule = this.rules.forNode(node)
    // var content = process.call(this, node)
    // var whitespace = node.flankingWhitespace
    // if (whitespace.leading || whitespace.trailing) content = content.trim()
    // return (
    //   whitespace.leading +
    //   rule.replacement(content, node, this.options) +
    //   whitespace.trailing
    // )

  }

  escape(String input) {
    return 
      input.replaceAllMapped(new RegExp(r'\\(\S)'), (match) => '\\\\${match[1]}') // Escape backslash escapes!
      .replaceAllMapped(new RegExp(r'^(#{1,6} )', multiLine: true), (match) => '\\${match[1]}')         // Escape headings
      .replaceAllMapped(new RegExp(r'^([-*_] *){3,}$', multiLine: true), (match) {
        return match[0].split(match[1]).join('\\${match[1]}');
      })
      .replaceAllMapped(new RegExp(r'^(\W* {0,3})(\d+)\. ', multiLine: true), (match) => '${match[1]}${match[2]}\\. ')
      .replaceAllMapped(new RegExp(r'^([^\\\w]*)[*+-] ', multiLine: true), (match) {
        return match[0].replaceAllMapped(new RegExp(r'([*+-])'), (match) => '\\${match[1]}');
      })
      .replaceAllMapped(new RegExp(r'^(\W* {0,3})> '), (match) => '${match[1]}\\> ')
      .replaceAllMapped(new RegExp(r'\*+(?![*\s\W]).+?\*+'), (match) => match[0].replaceAll(new RegExp(r'\*'), '\\*'))
      .replaceAllMapped(new RegExp(r'_+(?![_\s\W]).+?_+'), (match) => match[0].replaceAll(new RegExp(r'_'), '\\_'))
      .replaceAllMapped(new RegExp(r'`+(?![`\s\W]).+?`+'), (match) => match[0].replaceAll(new RegExp(r'`'), '\\`'))
      .replaceAllMapped(new RegExp(r'[\[\]]'), (match) => '\\${match[0]}')
      ;
  }
}

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
  static const List<String> linkReferenceStyle = const [null, 'full', 'collapsed', 'shortcut'];
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

  static Map<String, String> toMap() {
    return {
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
  }
}
